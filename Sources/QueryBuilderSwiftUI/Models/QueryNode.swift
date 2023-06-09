//
//  QueryNode.swift
//  QueryBuilder
//
//  Created by Shyam Kumar on 3/25/23.
//

import Foundation

public class QueryNode<U: Queryable>: AnyQueryNode, Identifiable {
    var comparator: Comparator
    var compareToValue: any IsComparable
    var comparableObject: U.Type
    var objectKeyPath: PartialKeyPath<U>
    var link: QueryLink?
    public var id: String = UUID().uuidString
    
    init(comparator: Comparator, compareToValue: any IsComparable, comparableObject: U.Type, objectKeyPath: PartialKeyPath<U>) {
        self.comparator = comparator
        self.compareToValue = compareToValue
        self.comparableObject = comparableObject
        self.objectKeyPath = objectKeyPath
    }
    
    func addNode<ValueType: IsComparable>(keypath: PartialKeyPath<U>, compareTo: ValueType, comparator: Comparator, connectWith: QueryEval) {
        let currentNode = QueryNode<U>(
            comparator: comparator,
            compareToValue: compareTo,
            comparableObject: U.self,
            objectKeyPath: keypath
        )
        switch connectWith {
        case .and:
            let link: QueryLink = .and(currentNode)
            addLink(with: self, link: link)
        case .or:
            let link: QueryLink = .or(currentNode)
            addLink(with: self, link: link)
        }
    }
    
    func addNode(node: QueryNode<U>, connectWith queryEval: QueryEval) {
        addNode(keypath: node.objectKeyPath, compareTo: node.compareToValue, comparator: node.comparator, connectWith: queryEval)
    }
    
    func evaluate(_ obj: any Queryable) -> Bool {
        guard let obj = obj as? U else {
            Logger.log(
                "Type of Queryable object \(obj) passed to `evaluate` does not match expected type \(String(describing: U.self)), returning false",
                severity: .error
            )
            return false
        }
        guard let objectValueRaw = obj[keyPath: objectKeyPath] as? (any IsComparable) else {
            Logger.log(
                "Type of object at keypath \(objectKeyPath) of object type \(String(describing: U.self)) does not conform to `IsComparable`, returning false",
                severity: .error
            )
            return false
        }
        let objectValue = objectValueRaw.translateOption()
        let currentNodeValue = compareToValue.evaluate(comparator: comparator, against: objectValue)
        guard let link else { return currentNodeValue }
        switch link {
        case .and(let node): return currentNodeValue && node.evaluate(obj)
        case .or(let node):
            return currentNodeValue || node.evaluate(obj)
        }
    }
    
    func serialize() -> SerializedQueryNode {
        switch link {
        case .none:
            return SerializedQueryNode(comparator: comparator, compareToValue: compareToValue, objectKeyPath: U.stringFor(objectKeyPath), link: nil, linkedNode: nil)
        case .and(let node):
            return SerializedQueryNode(comparator: comparator, compareToValue: compareToValue, objectKeyPath: U.stringFor(objectKeyPath), link: .and, linkedNode: node.serialize())
        case .or(let node):
            return SerializedQueryNode(comparator: comparator, compareToValue: compareToValue, objectKeyPath: U.stringFor(objectKeyPath), link: .or, linkedNode: node.serialize())
        }
    }
    
    private func addLink(with node: AnyQueryNode, link: QueryLink) {
        // DO NOT REFACTOR
        // Was done this way because enums are value types
        if node.link != nil {
            switch node.link {
            case .and(let node):
                addLink(with: node, link: link)
            case .or(let node):
                addLink(with: node, link: link)
            case .none:
                return
            }
        } else {
            node.link = link
        }
    }
}
