//
//  Conformance.swift
//  QueryBuilder
//
//  Created by Shyam Kumar on 3/25/23.
//

import Foundation

extension Comparable where Self: IsComparable {
    func evaluate(comparator: Comparator, against value: any IsComparable) -> Bool {
        guard let value = value as? Self else {
            // TODO: - Throw error here
            return false
        }
        switch comparator {
        case .less:
            return self < value
        case .greater:
            return self > value
        case .lessThanOrEqual:
            return self <= value
        case .greaterThanOrEqual:
            return self >= value
        case .equal:
            return self == value
        case .notEqual:
            return self != value
        }
    }
}

extension Bool: IsComparable {
    func getValidComparators() -> [Comparator] {
        [.equal, .notEqual]
    }
    
    func evaluate(comparator: Comparator, against value: any IsComparable) -> Bool {
        guard let value = value as? Bool else {
            // TODO: - Throw error here
            return false
        }
        // TODO: - Replace print statements with logs
        switch comparator {
        case .less:
            print("Bool comparison does not support <, running != instead")
            return self != value
        case .greater:
            print("Bool comparsion does not support >, running != instead")
            return self != value
        case .lessThanOrEqual:
            print("Bool comparison does not support <=, running == instead")
            return self == value
        case .greaterThanOrEqual:
            print("Bool comparison does not support >=, running == instead")
            return self == value
        case .equal:
            return self == value
        case .notEqual:
            return self != value
        }
    }
    
    static func createAssociatedViewModel(options: [(any IsComparable)], startingValue: (any IsComparable)?) -> BoolComparableViewModel {
        BoolComparableViewModel(value: startingValue as? Bool)
    }
}

extension Date: IsComparable {
    static func createAssociatedViewModel(options: [(any IsComparable)], startingValue: (any IsComparable)?) -> DateComparableViewModel {
        DateComparableViewModel(value: startingValue as? Date)
    }
}
extension String: IsComparable {
    static func createAssociatedViewModel(options: [(any IsComparable)], startingValue: (any IsComparable)?) -> StringComparableViewModel {
        return StringComparableViewModel(value: startingValue as? String, options: options)
    }
}
extension Int: IsComparable {
    static func createAssociatedViewModel(options: [(any IsComparable)], startingValue: (any IsComparable)?) -> EmptyComparableViewModel {
        EmptyComparableViewModel()
    }
}
extension Double: IsComparable {
    typealias ViewModelType = EmptyComparableViewModel

    static func createAssociatedViewModel(options: [(any IsComparable)], startingValue: (any IsComparable)?) -> EmptyComparableViewModel {
        EmptyComparableViewModel()
    }
}
extension Float: IsComparable {
    static func createAssociatedViewModel(options: [(any IsComparable)], startingValue: (any IsComparable)?) -> EmptyComparableViewModel {
        EmptyComparableViewModel()
    }
}
