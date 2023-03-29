//
//  DateComparableView.swift
//  QueryBuilder
//
//  Created by Shyam Kumar on 3/26/23.
//

import SwiftUI

@available(iOS 13.0, *)
public final class DateComparableViewModel: ObservableObject, ComparableViewModel {
    @Published var value: Date = Date()
    
    init(value: Date?) {
        if let value {
            self.value = value
        }
    }
    
    public func getValue() -> Date { return value }
    
    public func createView() -> DateComparableView { DateComparableView(viewModel: self) }
}

@available(iOS 16.0, *)
public struct DateComparableView: ComparableView {
    @ObservedObject public var viewModel: DateComparableViewModel
    @State private var shouldShowSheet: Bool = false
    
    public var body: some View {
        Text(viewModel.value.formatted())
            .modifier(InsetText(color: .red))
            .onTapGesture { shouldShowSheet.toggle() }
            .sheet(isPresented: $shouldShowSheet) {
                VStack {
                    Text("Select date")
                        .font(.system(.headline, design: .monospaced, weight: .bold))
                    DatePicker(selection: $viewModel.value, in: ...Date.now, displayedComponents: [.date, .hourAndMinute]) {
                        Text("Select a date")
                    }
                    .labelsHidden()
                }
                .presentationDetents([.fraction(0.15)])
            }
    }
    
    public static func create(_ viewModel: DateComparableViewModel) -> DateComparableView {
        return DateComparableView(viewModel: viewModel)
    }
}

struct DateComparableView_Previews: PreviewProvider {
    static var previews: some View {
        DateComparableView(viewModel: DateComparableViewModel(value: nil))
    }
}
