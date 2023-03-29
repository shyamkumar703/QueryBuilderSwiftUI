//
//  EmptyComparableView.swift
//  QueryBuilder
//
//  Created by Shyam Kumar on 3/26/23.
//

import SwiftUI

class EmptyComparableViewModel: ComparableViewModel {
    func getValue() -> Int { 1 }
    
    func createView() -> EmptyComparableView {
        EmptyComparableView(viewModel: self)
    }
}

@available(iOS 13.0, *)
struct EmptyComparableView: ComparableView {
    var viewModel: EmptyComparableViewModel
    
    var body: some View {
        Text("Empty")
    }
    
    static func create(_ viewModel: EmptyComparableViewModel) -> EmptyComparableView {
        EmptyComparableView(viewModel: viewModel)
    }
}

@available(iOS 13.0, *)
struct EmptyComparableView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyComparableViewModel().createView()
    }
}
