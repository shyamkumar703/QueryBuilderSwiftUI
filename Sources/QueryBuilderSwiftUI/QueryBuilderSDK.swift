//
//  QueryBuilderSDK.swift
//  QueryBuilder
//
//  Created by Shyam Kumar on 3/28/23.
//

import Foundation

public class QueryBuilderSDK {
    private static var internalComparableTypes: [(any IsComparable.Type)] = [
        ComparableDate.self,
        String.self,
        Int.self,
        Double.self,
        Bool.self
    ]
    
    private static var externalComparableTypes: [(any IsComparable.Type)] = []
    
    public static func setComparableTypes(to array: [(any IsComparable.Type)]) {
        self.externalComparableTypes = array
    }
    
    public static func evaluate<QueryableElement: Queryable>(node: QueryNode<QueryableElement>, on array: [QueryableElement]) -> [QueryableElement] {
        return array.filter({ node.evaluate($0) })
    }
    
    static func anyComparable(from data: Data, type: String) throws -> (any IsComparable) {
        guard let comparableType = (internalComparableTypes + externalComparableTypes)
            .filter({ String(describing: $0) == type })
            .first else {
            throw QueryBuilderError.invalidAnyComparable
        }
        
        guard let castType = try? JSONDecoder().decode(comparableType, from: data) else {
            throw QueryBuilderError.decodingError
        }
        
        return castType
    }
    
    static func fetchFilters<QueryableElement: Queryable>(for type: QueryableElement.Type) -> [(name: String, node: QueryNode<QueryableElement>)] {
        let userDefaultsKey = String(describing: QueryableElement.self)
        let filters: [String] = UserDefaults.standard.object(forKey: userDefaultsKey) as? [String] ?? []
        if filters.isEmpty { return [] }
        
        var nameNodeArray = [(name: String, node: QueryNode<QueryableElement>)]()
        for filter in filters {
            guard let nodeData = UserDefaults.standard.object(forKey: filter) as? Data,
                  let serializedNode = try? JSONDecoder().decode(SerializedQueryNode.self, from: nodeData),
                  let queryNode = try? serializedNode.deserialize(to: QueryableElement.self) else {
                continue
            }
            nameNodeArray.append((filter, queryNode))
        }
        
        return nameNodeArray
    }
    
    static func save<QueryableElement: Queryable>(node: QueryNode<QueryableElement>, with name: String) throws {
        do {
            let userDefaultsKey = String(describing: QueryableElement.self)
            let filters: [String] = UserDefaults.standard.object(forKey: userDefaultsKey) as? [String] ?? []
            if filters.contains(name) { throw QueryBuilderError.duplicateName }
            
            let serializedNode = node.serialize()
            let json = try JSONEncoder().encode(serializedNode)
            
            UserDefaults.standard.set(json, forKey: name)
            UserDefaults.standard.set(filters + [name], forKey: userDefaultsKey)
        } catch {
            print(error)
            throw QueryBuilderError.serializationFailed
        }
    }
    
    static func removeNode<QueryableElement: Queryable>(with name: String, type: QueryableElement.Type) {
        // Remove key from queryableElement filters
        let userDefaultsKey = String(describing: QueryableElement.self)
        let filters: [String] = UserDefaults.standard.object(forKey: userDefaultsKey) as? [String] ?? []
        let newFilters = filters.filter({ $0 != name })
        UserDefaults.standard.set(newFilters, forKey: userDefaultsKey)
        // Remove node from UD
        UserDefaults.standard.removeObject(forKey: name)
        UserDefaults.standard.synchronize()
    }
}

// MARK: - Error
extension QueryBuilderSDK {
    enum QueryBuilderError: Error {
        case invalidAnyComparable
        case serializationFailed
        case duplicateName
        case nodeNotFound
        case decodingError
    }
}
