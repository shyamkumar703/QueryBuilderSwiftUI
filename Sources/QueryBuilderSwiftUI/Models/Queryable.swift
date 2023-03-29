//
//  Queryable.swift
//  QueryBuilder
//
//  Created by Shyam Kumar on 3/25/23.
//

import Foundation
import SwiftUI

public protocol Queryable: AnyObject {
    static var queryableParameters: [PartialKeyPath<Self>: any IsComparable.Type] { get set }
    static func stringFor(_ keypath: PartialKeyPath<Self>) -> String
    static func keypathFor(_ string: String) throws -> PartialKeyPath<Self>
}

protocol AnyQueryNode: AnyObject {
    var comparator: Comparator { get }
    var link: QueryLink? { get set }
    
    func evaluate(_ obj: any Queryable) -> Bool
    func serialize() -> SerializedQueryNode
}

public protocol IsComparable: Codable {
    associatedtype ViewModelType: ComparableViewModel
    func evaluate(comparator: Comparator, against value: any IsComparable) -> Bool
    func getValidComparators() -> [Comparator]
    static func createAssociatedViewModel(options: [(any IsComparable)], startingValue: (any IsComparable)?) -> ViewModelType
}

extension IsComparable {
    public func getValidComparators() -> [Comparator] { Comparator.allCases }
}

public enum Comparator: String, CaseIterable, Codable {
    case less = "less than"
    case greater = "greater than"
    case lessThanOrEqual = "less than or equal to"
    case greaterThanOrEqual = "greater than or equal to"
    case equal = "equal to"
    case notEqual = "not equal to"
    
    static func validComparators(for value: any IsComparable) -> [Comparator] {
        if value as? Bool != nil { return [.notEqual, .equal] }
        return Self.allCases
    }
}

enum QueryEval: String, Codable {
    case and
    case or
    
    mutating func toggle() {
        switch self {
        case .and: self = .or
        case .or: self = .and
        }
    }
    
    var color: Color {
        switch self {
        case .and: return Color.green
        case .or: return Color.purple
        }
    }
}

enum QueryLink {
    case and(AnyQueryNode)
    case or(AnyQueryNode)
    
    func value() -> AnyQueryNode {
        switch self {
        case .and(let node): return node
        case .or(let node): return node
        }
    }
}

extension Collection where Element: Queryable {
    func evaluate(node: QueryNode<Element>) -> [Self.Element] {
        return self.filter({ node.evaluate($0) })
    }
}
