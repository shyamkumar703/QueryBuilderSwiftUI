//
//  QueryBuilderView.swift
//  QueryBuilder
//
//  Created by Shyam Kumar on 3/27/23.
//

import SwiftUI

class QueryBuilderViewModel<QueryableElement: Queryable>: ObservableObject {
    @Published var views: [QueryView] = []
    @Published var filterName: String = ""
    @Published var isShowingFilterSaveAlert: Bool = false
    @Binding var currentFilter: (String, QueryNode<QueryableElement>)?
    @Binding var filteredItems: [QueryableElement]?
    
    var initialFilterName: String?
    
    var elements: [QueryableElement]
    
    enum QueryView: Identifiable {
        case predicate(QueryPredicateViewModel<QueryableElement>)
        case connector(ConnectorViewModel)
        
        var id: UUID {
            switch self {
            case .predicate(let qpvm): return qpvm.id
            case .connector(let cvm): return cvm.id
            }
        }
    }
    
    init(currentFilter: Binding<(String, QueryNode<QueryableElement>)?>, filteredItems: Binding<[QueryableElement]?>, elements: [QueryableElement], node: QueryNode<QueryableElement>? = nil, name: String? = nil) {
        self._currentFilter = currentFilter
        self.elements = elements
        self.initialFilterName = name
        self._filteredItems = filteredItems
        
        if let node {
            // convert node to vm
            createViews(from: node)
            if let name { self.filterName = name }
        }
    }
    
    private func createViews(from node: QueryNode<QueryableElement>) {
        views.append(.predicate(QueryPredicateViewModel(elements: elements, node: node)))
        switch node.link {
        case .none: return
        case .and(let node):
            views.append(.connector(ConnectorViewModel(queryEval: .and)))
            if let node = node as? QueryNode<QueryableElement> {
                createViews(from: node)
            }
        case .or(let node):
            views.append(.connector(ConnectorViewModel(queryEval: .or)))
            if let node = node as? QueryNode<QueryableElement> {
                createViews(from: node)
            }
        }
    }
    
    func save() {
        var node: QueryNode<QueryableElement>?
        switch views.first {
        case .predicate(let predicateView):
            node = predicateView.createQueryNode()
        default:
            // TODO: - Error handle appropriately
            return
        }
        
        var currentIndex = 2
        while currentIndex < views.count {
            if case let .connector(cvm) = views[currentIndex - 1],
               case let .predicate(qpv) = views[currentIndex] {
                node?.addNode(node: qpv.createQueryNode(), connectWith: cvm.queryEval)
                currentIndex += 1
            } else {
                // TODO: - Error handle appropriately
                return
            }
        }
        
        guard let node else {
            // TODO: - Error-handle appropriately here
            return
        }
        
        do {
            // save here
            // if initialName is nil, save and append
            // if initialName is non-nil and initialName != filterName, remove(initialName), save(filterName), filter and append
            if initialFilterName == nil {
                try QueryBuilderSDK.save(node: node, with: filterName)
                currentFilter = (filterName, node)
                filteredItems = elements.filter({ node.evaluate($0) })
            } else if let initialFilterName {
                QueryBuilderSDK.removeNode(with: initialFilterName, type: QueryableElement.self)
                try QueryBuilderSDK.save(node: node, with: filterName)
                currentFilter = (filterName, node)
                filteredItems = elements.filter({ node.evaluate($0) })
            }
            
        } catch {
            // TODO: - Error handle appropriately
            print(error)
        }
    }
    
    func onAppear() {
        if views.count == 0 {
            views.append(.predicate(QueryPredicateViewModel<QueryableElement>(elements: elements)))
        }
    }
    
    func createView() -> QueryBuilderView<QueryableElement> {
        return QueryBuilderView(viewModel: self)
    }
    
    func delete(_ predicateVM: QueryPredicateViewModel<QueryableElement>) {
        for (index, view) in views.enumerated() {
            switch view {
            case .predicate(let vm):
                guard vm.id == predicateVM.id else { continue }
                remove(from: index)
                return
            default: continue
            }
        }
    }
    
    private func remove(from index: Int) {
        views.remove(at: index)
        if index + 1 < views.count {
            views.remove(at: index + 1)
        }
    }
}

struct QueryBuilderView<QueryableElement: Queryable>: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: QueryBuilderViewModel<QueryableElement>
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    ForEach(viewModel.views) { viewCase in
                        switch viewCase {
                        case .connector(let connector):
                            connector.createView()
                        case .predicate(let predicate):
                            predicate.createView()
                        }
                    }
                    
                    AddButton(title: "Add condition") {
                        withAnimation {
                            viewModel.views += [
                                .connector(ConnectorViewModel()),
                                .predicate(QueryPredicateViewModel<QueryableElement>(elements: viewModel.elements))
                            ]
                        }
                    }
                }
            }
            .navigationTitle(viewModel.filterName.isEmpty ? "New filter" : viewModel.filterName)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(
                        action: {
                            viewModel.isShowingFilterSaveAlert = true
                        },
                        label: {
                            Text("Save")
                        }
                    )
                    .alert(viewModel.filterName.isEmpty ? "Enter a name": "Edit name", isPresented: $viewModel.isShowingFilterSaveAlert) {
                        TextField("Filter name", text: $viewModel.filterName)
                        Button("Cancel") {
                            viewModel.isShowingFilterSaveAlert.toggle()
                        }
                        Button("Save", action: save)
                    }
                }
            }
        }
        .onAppear {
            viewModel.onAppear()
        }
    }
    
    func save() {
        viewModel.save()
        dismiss()
    }
}
