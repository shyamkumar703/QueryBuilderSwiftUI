//
//  DateComparableView.swift
//  QueryBuilder
//
//  Created by Shyam Kumar on 3/26/23.
//

import SwiftUI

@available(iOS 13.0, *)
public final class DateComparableViewModel: ObservableObject, ComparableViewModel {
    @Published var value: ComparableDate = .relativeDate(.today)
    
    public init(value: ComparableDate?) {
        if let value {
            self.value = value
        }
    }
    
    public func getValue() -> ComparableDate { return value }
    
    public func createView() -> DateComparableView { DateComparableView(viewModel: self) }
    
    var dateValue: Date {
        switch value {
        case .date(let date): return date
        case .relativeDate(let relativeDate): return relativeDate.date ?? Date()
        }
    }
    
    var displayString: String {
        switch value {
        case .date(let date): return date.formatted()
        case .relativeDate(let relativeDate): return relativeDate.rawValue
        }
    }
    
    var relativeDateOptions: [RelativeDateOption] {
        switch value {
        case .date:
            return RelativeDate.allCases.map({ RelativeDateOption.relativeDate($0) }) + [.switchToAbsolute]
        case .relativeDate(let relativeDate):
            return RelativeDate.allCases.filter({ $0 != relativeDate }).map({ RelativeDateOption.relativeDate($0) }) + [.switchToAbsolute]
        }
    }
    
    enum RelativeDateOption {
        case relativeDate(RelativeDate)
        case switchToAbsolute
        
        var displayValue: String {
            switch self {
            case .relativeDate(let rd): return rd.rawValue
            case .switchToAbsolute: return "Absolute date"
            }
        }
    }
    
    enum AbsoluteDateOption: String, CaseIterable {
        case switchToRelative = "Relative date"
        case selectDate = "Select date"
    }
}

@available(iOS 16.0, *)
public struct DateComparableView: ComparableView {
    @ObservedObject public var viewModel: DateComparableViewModel
    @State private var shouldShowSheet: Bool = false
    @State private var intermediateDate = Date()
    
    public var body: some View {
        switch viewModel.value {
        case .relativeDate:
            relativeDateView
        case .date:
            absoluteDateView
        }
    }
    
    @ViewBuilder var selectDateSheet: some View {
        VStack {
            Text("Select date")
                .font(.system(.headline, design: .monospaced, weight: .bold))
            DatePicker(selection: $intermediateDate, in: ...Date.now, displayedComponents: [.date, .hourAndMinute]) {
                Text("Select a date")
            }
            .labelsHidden()
        }
        .presentationDetents([.fraction(0.15)])
    }
    
    @ViewBuilder var absoluteDateView: some View {
        Menu(
            content: {
                ForEach(DateComparableViewModel.AbsoluteDateOption.allCases, id: \.rawValue) { value in
                    switch value {
                    case .selectDate:
                        Button(value.rawValue) {
                            shouldShowSheet.toggle()
                        }
                    case .switchToRelative:
                        Button(value.rawValue) {
                            viewModel.value = .relativeDate(.today)
                        }
                    }
                }
            },
            label: {
                Text(viewModel.displayString)
                    .modifier(InsetText(color: .red))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        )
        .sheet(isPresented: $shouldShowSheet) { selectDateSheet }
        .onChange(of: intermediateDate) { newValue in viewModel.value = .date(newValue) }
    }
    
    @ViewBuilder var relativeDateView: some View {
        Menu(
            content: {
                ForEach(viewModel.relativeDateOptions, id: \.displayValue) { value in
                    switch value {
                    case .relativeDate(let value):
                        Button(
                            action: {
                                viewModel.value = .relativeDate(value)
                            },
                            label: {
                                Text(value.rawValue)
                            }
                        )
                    case .switchToAbsolute:
                        Button(value.displayValue) {
                            viewModel.value = .date(Date())
                        }
                    }
                }
            },
            label: {
                Text(viewModel.displayString)
                    .modifier(InsetText(color: .red))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        )
        .contextMenu {
            Button("Absolute date") {
                viewModel.value = .date(Date())
            }
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
