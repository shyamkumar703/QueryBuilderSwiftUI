//
//  ComparatorView.swift
//  QueryBuilder
//
//  Created by Shyam Kumar on 3/26/23.
//

import SwiftUI

struct ComparatorView: View {
    @Binding var selectedComparator: Comparator
    var validComparators: [Comparator]
    
    var body: some View {
        Menu(
            content: {
                ForEach(validComparators.filter({ $0 != selectedComparator }), id: \.rawValue) { comparator in
                    Button(
                        action: {
                            self.selectedComparator = comparator
                        },
                        label: {
                            Text(comparator.rawValue)
                        }
                    )
                }
            },
            label: {
                viewFrom(selectedComparator)
            }
        )
    }
    
    private func viewFrom(_ comparator: Comparator, noop: Bool = false) -> AnyView {
        switch comparator {
        case .less:
            return AnyView(
                Image(systemName: "lessthan")
                    .font(.caption2.weight(.bold).monospaced())
                    .foregroundColor(.blue)
                    .modifier(InsetSymbol(noop: noop))
            )
        case .greater:
            return AnyView(
                Image(systemName: "greaterthan")
                    .font(.caption2.weight(.bold).monospaced())
                    .foregroundColor(.blue)
                    .modifier(InsetSymbol(noop: noop))
            )
        case .equal:
            return AnyView(
                Image(systemName: "equal")
                    .font(.caption2.weight(.bold).monospaced())
                    .foregroundColor(.blue)
                    .modifier(InsetSymbol(noop: noop))
            )
        case .lessThanOrEqual:
            return AnyView(
                HStack(spacing: 0) {
                    Image(systemName: "lessthan")
                        .font(.caption2.weight(.bold).monospaced())
                        .foregroundColor(.blue)
                    Image(systemName: "equal")
                        .font(.caption2.weight(.bold).monospaced())
                        .foregroundColor(.blue)
                }
                .modifier(InsetSymbol(noop: noop))
            )
        case .greaterThanOrEqual:
            return AnyView(
                HStack(spacing: 0) {
                    Image(systemName: "greaterthan")
                        .font(.caption2.weight(.bold).monospaced())
                        .foregroundColor(.blue)
                    Image(systemName: "equal")
                        .font(.caption2.weight(.bold).monospaced())
                        .foregroundColor(.blue)
                }
                .modifier(InsetSymbol(noop: noop))
            )
        case .notEqual:
            return AnyView(
                ZStack {
                    Image(systemName: "equal")
                        .font(.caption2.weight(.bold).monospaced())
                        .foregroundColor(.blue)
                    Image(systemName: "line.diagonal")
                        .font(.caption2.weight(.bold).monospaced())
                        .foregroundColor(.blue)
                }
                .modifier(InsetSymbol(noop: noop))
            )
        }
    }
}

struct InsetSymbol: ViewModifier {
    private var noop: Bool
    
    init(noop: Bool = false) {
        self.noop = noop
    }
    
    func body(content: Content) -> some View {
        if noop {
            return AnyView(content)
        } else {
            return AnyView(
                content
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .foregroundColor(.blue.opacity(0.2))
                    )
            )
        }
    }
}

struct ComparatorView_Previews: PreviewProvider {
    static var previews: some View {
        ComparatorView(selectedComparator: .constant(.less), validComparators: Comparator.allCases)
            .preferredColorScheme(.dark)
    }
}
