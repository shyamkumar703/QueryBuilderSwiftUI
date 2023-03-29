//
//  QueryNode.swift
//  QueryBuilder
//
//  Created by Shyam Kumar on 3/25/23.
//

import Foundation

class QueryNode<U: Queryable>: AnyQueryNode, Identifiable {
    var comparator: Comparator
    var compareToValue: any IsComparable
    var comparableObject: U.Type
    var objectKeyPath: PartialKeyPath<U>
    var link: QueryLink?
    var id: String = UUID().uuidString
    
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
            // TODO: - Error handle
            return false
        }
        guard let objectValue = obj[keyPath: objectKeyPath] as? (any IsComparable) else {
            // TODO: - Error handle
            return false
        }
        let currentNodeValue = objectValue.evaluate(comparator: comparator, against: compareToValue)
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
        if node.link != nil {
            switch node.link {
            case .and(let node):
                addLink(with: node, link: link)
            case .or(let node):
                addLink(with: node, link: link)
            case .none:
                // TODO: - Error handling
                return
            }
        } else {
            node.link = link
        }
    }
}
