//
//  BoolComparableView.swift
//  QueryBuilder
//
//  Created by Shyam Kumar on 3/26/23.
//

import SwiftUI

@available(iOS 13.0, *)
protocol ComparableView: View {
    associatedtype ViewModelType: ComparableViewModel
    var viewModel: ViewModelType { get }
    static func create(_ viewModel: ViewModelType) -> Self
}

protocol ComparableViewModel: AnyObject {
    associatedtype ValueType: IsComparable
    associatedtype ViewType: ComparableView
    
    func createView() -> ViewType
    func getValue() -> ValueType
}

final class BoolComparableViewModel: ObservableObject, ComparableViewModel {
    @Published var value: Bool = true
    
    init(value: Bool?) {
        if let value {
            self.value = value
        }
    }
    
    func getValue() -> Bool { return value }
    
    func createView() -> BoolComparableView { BoolComparableView(viewModel: self) }
}

struct BoolComparableView: ComparableView {
    @ObservedObject var viewModel: BoolComparableViewModel
    
    var body: some View {
        Text(viewModel.value ? "true": "false")
            .modifier(InsetText(color: .red))
            .onTapGesture {
                viewModel.value.toggle()
            }
    }
    
    static func create(_ viewModel: BoolComparableViewModel) -> BoolComparableView {
        BoolComparableView(viewModel: viewModel)
    }
}

struct BoolComparableView_Previews: PreviewProvider {
    static var previews: some View {
        BoolComparableView.create(BoolComparableViewModel(value: nil))
    }
}
