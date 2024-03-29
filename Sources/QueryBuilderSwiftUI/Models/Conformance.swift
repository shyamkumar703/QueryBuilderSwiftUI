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
            Logger.log(
                "Value \(value) passed into `evaluate` is not a \(String(describing: type(of: self))), returning false",
                severity: .error
            )
            return false
        }
        switch comparator {
        case .less:
            return value < self
        case .greater:
            return value > self
        case .lessThanOrEqual:
            return value <= self
        case .greaterThanOrEqual:
            return value >= self
        case .equal:
            return value == self
        case .notEqual:
            return value != self
        }
    }
}

extension Bool: IsComparable {
    public static func getValidComparators() -> [Comparator] {
        [.equal, .notEqual]
    }
    
    public func evaluate(comparator: Comparator, against value: any IsComparable) -> Bool {
        guard let value = value as? Bool else {
            Logger.log("Value \(value) passed into `evaluate` is not a boolean, returning false", severity: .error)
            return false
        }

        switch comparator {
        case .less:
            Logger.log("Bool comparison does not support <, running != instead", severity: .warning)
            return self != value
        case .greater:
            Logger.log("Bool comparsion does not support >, running != instead", severity: .warning)
            return self != value
        case .lessThanOrEqual:
            Logger.log("Bool comparison does not support <=, running == instead", severity: .warning)
            return self == value
        case .greaterThanOrEqual:
            Logger.log("Bool comparison does not support >=, running == instead", severity: .warning)
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
        DateComparableViewModel(value: startingValue as? ComparableDate)
    }
}
extension String: IsComparable {
    public static func getValidComparators() -> [QueryBuilderSwiftUI.Comparator] {
        [.equal, .notEqual]
    }
    
    public static func createAssociatedViewModel(options: [(any IsComparable)], startingValue: (any IsComparable)?) -> StringComparableViewModel {
        return StringComparableViewModel(value: startingValue as? String, options: options)
    }
    
    public func evaluate(comparator: QueryBuilderSwiftUI.Comparator, against value: any IsComparable) -> Bool {
        guard let value = value as? String else {
            Logger.log("Value \(value) passed into `evaluate` is not a string, returning false", severity: .error)
            return false
        }

        switch comparator {
        case .less:
            Logger.log("String comparison does not support <, running != instead", severity: .warning)
            return self != value
        case .greater:
            Logger.log("String comparsion does not support >, running != instead", severity: .warning)
            return self != value
        case .lessThanOrEqual:
            Logger.log("String comparison does not support <=, running == instead", severity: .warning)
            return self == value
        case .greaterThanOrEqual:
            Logger.log("String comparison does not support >=, running == instead", severity: .warning)
            return self == value
        case .equal:
            return self == value
        case .notEqual:
            return self != value
        }
    }
}
extension Int: IsComparable {
    public static func createAssociatedViewModel(options: [(any IsComparable)], startingValue: (any IsComparable)?) -> IntComparableViewModel {
        IntComparableViewModel(value: startingValue as? Int, options: options)
    }
}
extension Double: IsComparable {
    public static func createAssociatedViewModel(options: [(any IsComparable)], startingValue: (any IsComparable)?) -> DoubleComparableViewModel {
        DoubleComparableViewModel(value: startingValue as? Double, options: options)
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
