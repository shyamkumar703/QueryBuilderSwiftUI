//
//  SerializedQueryNode.swift
//  QueryBuilder
//
//  Created by Shyam Kumar on 3/28/23.
//

import Foundation

final class SerializedQueryNode: Codable {
    var comparator: Comparator
    var compareToValue: any IsComparable
    var objectKeyPath: String
    var link: QueryEval?
    var linkedNode: SerializedQueryNode?
    var valueTypeString: String
    
    init(comparator: Comparator, compareToValue: any IsComparable, objectKeyPath: String, link: QueryEval?, linkedNode: SerializedQueryNode?) {
        self.comparator = comparator
        self.compareToValue = compareToValue
        self.objectKeyPath = objectKeyPath
        self.link = link
        self.linkedNode = linkedNode
        self.valueTypeString = String(describing: type(of: compareToValue))
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        comparator = try values.decode(Comparator.self, forKey: .comparator)
        valueTypeString = try values.decode(String.self, forKey: .valueTypeString)
        let compareToValueIntermediate = try values.decode(Data.self, forKey: .compareToValue)
        compareToValue = try QueryBuilderSDK.anyComparable(from: compareToValueIntermediate, type: valueTypeString)
        objectKeyPath = try values.decode(String.self, forKey: .objectKeyPath)
        link = try? values.decode(QueryEval?.self, forKey: .link)
        if link != nil {
            linkedNode = try values.decode(SerializedQueryNode?.self, forKey: .linkedNode)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(comparator, forKey: .comparator)
        let valueData = try JSONEncoder().encode(compareToValue)
        try container.encode(valueData, forKey: .compareToValue)
        try container.encode(objectKeyPath, forKey: .objectKeyPath)
        try container.encode(valueTypeString, forKey: .valueTypeString)
        if let link = link {
            try container.encode(link, forKey: .link)
            guard let linkedNode else { throw SerialzedQueryNodeError.linkWithoutLinkedNode }
            try container.encode(linkedNode, forKey: .linkedNode)
        }
    }
    
    func deserialize<QueryableElement: Queryable>(to nodeType: QueryableElement.Type) throws -> QueryNode<QueryableElement> {
        let keypath = try QueryableElement.keypathFor(objectKeyPath)
        let node = QueryNode(comparator: comparator, compareToValue: compareToValue, comparableObject: nodeType, objectKeyPath: keypath)
        if let link, let linkedNode {
            try node.addNode(node: linkedNode.deserialize(to: QueryableElement.self), connectWith: link)
        }
        
        return node
    }
    
    enum CodingKeys: String, CodingKey {
        case comparator
        case compareToValue
        case objectKeyPath
        case link
        case linkedNode
        case valueTypeString
    }
}

// MARK: - Errors
extension SerializedQueryNode {
    enum SerialzedQueryNodeError: Error {
        case linkWithoutLinkedNode
    }
}
    

enum SerializedQueryLink {
    case and(SerializedQueryNode)
    case or(SerializedQueryNode)
}
