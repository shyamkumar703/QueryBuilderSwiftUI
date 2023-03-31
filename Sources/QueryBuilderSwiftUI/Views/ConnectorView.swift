//
//  ConnectorView.swift
//  QueryBuilder
//
//  Created by Shyam Kumar on 3/27/23.
//

import SwiftUI

class ConnectorViewModel: ObservableObject, Identifiable {
    @Published var queryEval: QueryEval = .and
    var id: UUID = UUID()
    
    init(queryEval: QueryEval = .and) {
        self.queryEval = queryEval
    }
    
    func createView() -> ConnectorView {
        return ConnectorView(viewModel: self)
    }
    
    func toggleQueryEval() {
        queryEval.toggle()
    }
}

struct ConnectorView: View {
    @ObservedObject var viewModel: ConnectorViewModel
    
    var body: some View {
        HStack {
            Text(viewModel.queryEval.rawValue.uppercased())
                .modifier(InsetText(color: viewModel.queryEval.color))
                .onTapGesture {
                    viewModel.toggleQueryEval()
                }
            
            Spacer()
        }
    }
}

struct ConnectorView_Previews: PreviewProvider {
    static var previews: some View {
        ConnectorViewModel().createView()
    }
}
