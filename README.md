# QueryBuilder
## QueryBuilder is a lightweight iOS package that enables user-created filters.

QueryBuilder iOS allows users to directly interact with properties of objects you've exposed. Users can create their own custom ways to see only the data they're interested in without API access. This means that users can more effectively serve themselves without API access.

## Queryable
A protocol that exposes data-model properties for user interaction. Here's how you define a `Queryable` object:

```swift
import Foundation
import QueryBuilderSwiftUI

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
```

## QueryFilterView
The entry point to the QueryBuilder interface. Here's how you can add `QueryFilterView` into a SwiftUI view:

```swift
import SwiftUI
import QueryBuilderSwiftUI

struct ArticleList: View {
    @State private var articles: [Article] = [
        Article(id: UUID().uuidString, author: "Test 1", postedAt: Date(), likes: 50, isStarred: true),
        Article(id: UUID().uuidString, author: "Test 2", postedAt: Date(), likes: 50, isStarred: false),
        Article(id: UUID().uuidString, author: "Test 3", postedAt: Date(), likes: 100, isStarred: false)
    ]
    
    @State private var filteredArticles: [Article]?
    
    @State private var currentFilter: (String, QueryNode<Article>)?
    
    var body: some View {
        NavigationView {
            List {
                ForEach(filteredArticles ?? articles) { article in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(article.author)
                            Text(article.postedAt.formatted())
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            Text("\(article.likes) likes")
                            Text(article.isStarred ? "Starred": "Not starred")
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Articles")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    QueryFilterView(allItems: $articles, filteredItems: $filteredArticles, currentFilter: $currentFilter)
                }
            }
        }
    }
}
```
