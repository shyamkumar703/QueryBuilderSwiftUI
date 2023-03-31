//
//  IntComparableView.swift
//  
//
//  Created by Shyam Kumar on 3/31/23.
//

import SwiftUI

@available(iOS 13.0, *)
public final class IntComparableViewModel: ObservableObject, ComparableViewModel {
    @Published var value: Int = 0
    var options: [Int]?
    
    var minValue: Double {
        if let options {
            return Double(options.sorted().first ?? 0)
        } else {
            return 0
        }
    }
    
    var maxValue: Double {
        if let options {
            return Double(options.sorted().last ?? 1000)
        } else {
            return 1000
        }
    }
    
    var intProxy: Binding<Double> {
        Binding<Double>(
            get: { return Double(self.value) },
            set: { self.value = Int($0) }
        )
    }
    
    public init(value: Int?, options: [(any IsComparable)]) {
        self.options = options as? [Int]
        if let value {
            self.value = value
        } else {
            self.value = Int(minValue)
        }
    }
    
    public func getValue() -> Int { return value }
    
    public func createView() -> IntComparableView { IntComparableView(viewModel: self) }
}

public struct IntComparableView: ComparableView {
    @ObservedObject public var viewModel: IntComparableViewModel
    @State private var shouldShowSheet: Bool = false
    
    public var body: some View {
        Text("\(viewModel.value)")
            .modifier(InsetText(color: .red))
            .onTapGesture { shouldShowSheet.toggle() }
            .sheet(isPresented: $shouldShowSheet) {
                Slider(value: viewModel.intProxy, in: viewModel.minValue...viewModel.maxValue)
                    .padding()
                    .presentationDetents([.fraction(0.15)])
            }
    }

    public static func create(_ viewModel: IntComparableViewModel) -> IntComparableView {
        return IntComparableView(viewModel: viewModel)
    }
}

struct IntComparableView_Previews: PreviewProvider {
    static var previews: some View {
        IntComparableViewModel(value: nil, options: [1, 2, 3]).createView()
    }
}
