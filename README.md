# QueryBuilder
## QueryBuilder is a lightweight iOS package that enables user-created filters.

QueryBuilder iOS allows users to directly interact with properties of objects you've exposed. Users can create their own custom ways to see only the data they're interested in without API access. This means that users can more effectively serve themselves without API access.

![](https://github.com/shyamkumar703/QueryBuilderSwiftUI/blob/main/Kit/qb_example.gif)

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

## IsComparable
Conforming a data-type to `IsComparable` allows users to add comparisons relative to properties with said data-type into their custom filters. `Date`, `String`, `Int`, `Double`, and `Bool` already conform to `IsComparable`. If you need to add `IsComparable` conformance
to a custom data-type, follow these steps:

1) Add the conformance to your custom object

```swift
extension FeedEntry.Status: IsComparable {
    // Defines valid comparators users can use with this data-type
    static func getValidComparators() -> [QueryBuilderSwiftUI.Comparator] {
        [.equal, .notEqual]
    }
    
    // Called on query evaluation, should define comparison behavior
    func evaluate(comparator: QueryBuilderSwiftUI.Comparator, against value: any IsComparable) -> Bool {
        guard let value = value as? FeedEntry.Status else {
            return false
        }
        switch comparator {
        case .less:
            print("Status comparison does not support <, running != instead")
            return self != value
        case .greater:
            print("Status comparsion does not support >, running != instead")
            return self != value
        case .lessThanOrEqual:
            print("Status comparison does not support <=, running == instead")
            return self == value
        case .greaterThanOrEqual:
            print("Status comparison does not support >=, running == instead")
            return self == value
        case .equal:
            return self == value
        case .notEqual:
            return self != value
        }
    }
    
    // Creates the viewModel that will display the view to the user
    // StringComparableView, DateComparableView, IntComparableView, BoolComparableView, and DoubleComparableView are BUILT-IN
    // You can define the translateOption() function to convert your built-in data type to one of the above primitives
    static func createAssociatedViewModel(options: [(any IsComparable)], startingValue: (any IsComparable)?) -> StringComparableViewModel {
        return StringComparableViewModel(value: startingValue as? String, options: options)
    }
    
    // Called BEFORE createAssociatedViewModel to transform the custom data-type to a primitive, OPTIONAL
    func translateOption() -> any IsComparable { rawValue }
}
```

2) Declare your custom IsComparable objects in your AppDelegate

```swift
import QueryBuilderSwiftUI
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        QueryBuilderSDK.setComparableTypes(to: [FeedEntry.Status.self, Feed.self])
        return true
    }
}
```
