//
//  Article.swift
//  QueryBuilder
//
//  Created by Shyam Kumar on 3/25/23.
//

import Foundation

final class Article: Identifiable, Queryable {
    var id: String
    var author: String
    var postedAt: Date
    var likes: Int
    var isStarred: Bool
    
    static var queryableParameters: [PartialKeyPath<Article>: any IsComparable.Type] = [
        \Article.author: String.self,
        \Article.postedAt: Date.self,
        \Article.likes: Int.self,
        \Article.isStarred: Bool.self
    ]
    var queryNode: AnyQueryNode? = nil
    
    init(id: String, author: String, postedAt: Date, likes: Int, isStarred: Bool) {
        self.id = id
        self.author = author
        self.postedAt = postedAt
        self.likes = likes
        self.isStarred = isStarred
    }
    
    static func stringFor(_ keypath: PartialKeyPath<Article>) -> String {
        switch keypath {
        case \.author: return "Author"
        case \.postedAt: return "Posted time"
        case \.likes: return "Likes"
        case \.isStarred: return "Starred"
        default: return ""
        }
    }
    
    static func keypathFor(_ string: String) throws -> PartialKeyPath<Article> {
        switch string {
        case "Author": return \.author
        case "Posted time": return \.postedAt
        case "Likes": return \.likes
        case "Starred": return \.isStarred
        default: throw ArticleError.invalidKeypathString
        }
    }
}

extension Article {
    enum ArticleError: Error {
        case invalidKeypathString
    }
}


