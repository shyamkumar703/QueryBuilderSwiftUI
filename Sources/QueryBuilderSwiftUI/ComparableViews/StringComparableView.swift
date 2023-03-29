//
//  StringComparableView.swift
//  QueryBuilder
//
//  Created by Shyam Kumar on 3/28/23.
//

import SwiftUI

public class StringComparableViewModel: ObservableObject, ComparableViewModel {
    @Published var value: String = "A"
    var options: [(any IsComparable)]
    let alphabet: [String] = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
    
    var displayOptions: [String] {
        if let options = options as? [String],
           !options.isEmpty {
            return options
        } else {
            return alphabet
        }
    }
    
    var wasValueSet: Bool = false
    
    public init(value: String?, options: [(any IsComparable)]) {
        if let value {
            self.value = value
            wasValueSet = true
        }
        
        self.options = options
    }
    
    public func getValue() -> String { return value }
    
    public func createView() -> StringComparableView { StringComparableView(viewModel: self) }
    
    func onAppear() {
        if !wasValueSet {
            value = displayOptions.randomElement()!
        }
    }
    
}

public struct StringComparableView: ComparableView {
    @ObservedObject public var viewModel: StringComparableViewModel
    
    public var body: some View {
        Menu(
            content: {
                ForEach(viewModel.displayOptions.filter({ $0 != viewModel.value}).sorted(), id: \.self) { value in
                    Button(
                        action: {
                            viewModel.value = value
                        },
                        label: {
                            Text(value)
                        }
                    )
                }
            },
            label: {
                Text(viewModel.value)
                    .modifier(InsetText(color: .red))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        )
        .onAppear {
            viewModel.onAppear()
        }
    }
    
    public static func create(_ viewModel: StringComparableViewModel) -> StringComparableView {
        return StringComparableView(viewModel: viewModel)
    }
}

struct StringComparableView_Previews: PreviewProvider {
    static var previews: some View {
        StringComparableView.create(StringComparableViewModel(value: nil, options: ["test1", "test2"]))
    }
}
