//
//  EmptyComparableView.swift
//  QueryBuilder
//
//  Created by Shyam Kumar on 3/26/23.
//

import SwiftUI

public class EmptyComparableViewModel: ComparableViewModel {
    public func getValue() -> Int { 1 }
    
    public func createView() -> EmptyComparableView {
        EmptyComparableView(viewModel: self)
    }
}

@available(iOS 13.0, *)
public struct EmptyComparableView: ComparableView {
    public var viewModel: EmptyComparableViewModel
    
    public var body: some View {
        Text("Empty")
    }
    
    public static func create(_ viewModel: EmptyComparableViewModel) -> EmptyComparableView {
        EmptyComparableView(viewModel: viewModel)
    }
}

@available(iOS 13.0, *)
struct EmptyComparableView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyComparableViewModel().createView()
    }
}
