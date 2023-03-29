//
//  Conformance.swift
//  QueryBuilder
//
//  Created by Shyam Kumar on 3/25/23.
//

import Foundation

extension Comparable where Self: IsComparable {
    public func evaluate(comparator: Comparator, against value: any IsComparable) -> Bool {
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
    public static func getValidComparators() -> [Comparator] {
        [.equal, .notEqual]
    }
    
    public func evaluate(comparator: Comparator, against value: any IsComparable) -> Bool {
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
    
    public static func createAssociatedViewModel(options: [(any IsComparable)], startingValue: (any IsComparable)?) -> BoolComparableViewModel {
        BoolComparableViewModel(value: startingValue as? Bool)
    }
}

extension Date: IsComparable {
    public static func createAssociatedViewModel(options: [(any IsComparable)], startingValue: (any IsComparable)?) -> DateComparableViewModel {
        DateComparableViewModel(value: startingValue as? Date)
    }
}
extension String: IsComparable {
    public static func createAssociatedViewModel(options: [(any IsComparable)], startingValue: (any IsComparable)?) -> StringComparableViewModel {
        return StringComparableViewModel(value: startingValue as? String, options: options)
    }
}
extension Int: IsComparable {
    public static func createAssociatedViewModel(options: [(any IsComparable)], startingValue: (any IsComparable)?) -> EmptyComparableViewModel {
        EmptyComparableViewModel()
    }
}
extension Double: IsComparable {
    public static func createAssociatedViewModel(options: [(any IsComparable)], startingValue: (any IsComparable)?) -> EmptyComparableViewModel {
        EmptyComparableViewModel()
    }
}
extension Float: IsComparable {
    public static func createAssociatedViewModel(options: [(any IsComparable)], startingValue: (any IsComparable)?) -> EmptyComparableViewModel {
        EmptyComparableViewModel()
    }
}

extension Array where Element: Equatable {
    var unique: [Element] {
        var uniqueValues: [Element] = []
        forEach { item in
            guard !uniqueValues.contains(item) else { return }
            uniqueValues.append(item)
        }
        return uniqueValues
    }
}
