//
//  DoubleComparableView.swift
//  
//
//  Created by Shyam Kumar on 3/31/23.
//

import SwiftUI

@available(iOS 13.0, *)
public final class DoubleComparableViewModel: ObservableObject, ComparableViewModel {
    @Published var value: Double = 0
    var options: [Double]?
    
    var minValue: Double {
        options?.sorted().first ?? 0
    }
    
    var maxValue: Double {
        options?.sorted().last ?? 1000
    }
    
    public init(value: Double?, options: [(any IsComparable)]) {
        self.options = options as? [Double]
        if let value {
            self.value = value
        } else {
            self.value = Double(minValue)
        }
    }
    
    public func getValue() -> Double { return value }
    
    public func createView() -> DoubleComparableView { DoubleComparableView(viewModel: self) }
}

public struct DoubleComparableView: ComparableView {
    @ObservedObject public var viewModel: DoubleComparableViewModel
    @State private var shouldShowSheet: Bool = false
    
    public var body: some View {
        Text("\(viewModel.value.formatted())")
            .modifier(InsetText(color: .red))
            .onTapGesture { shouldShowSheet.toggle() }
            .sheet(isPresented: $shouldShowSheet) {
                Slider(value: $viewModel.value, in: viewModel.minValue...viewModel.maxValue)
                    .padding()
                    .presentationDetents([.fraction(0.15)])
            }
    }

    public static func create(_ viewModel: DoubleComparableViewModel) -> DoubleComparableView {
        return DoubleComparableView(viewModel: viewModel)
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        DoubleComparableViewModel(value: nil, options: [1, 2, 3]).createView()
    }
}
