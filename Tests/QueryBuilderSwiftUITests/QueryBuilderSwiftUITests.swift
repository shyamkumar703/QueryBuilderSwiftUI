import XCTest
@testable import QueryBuilderSwiftUI

final class QueryBuilderSwiftUITests: XCTestCase {
    func testNumberOfConditions_AddsCorrectly() {
        let queryNode = QueryNode(comparator: .greaterThanOrEqual, compareToValue: 100, comparableObject: Article.self, objectKeyPath: \Article.likes)
        queryNode.addNode(keypath: \Article.isStarred, compareTo: true, comparator: .equal, connectWith: .and)
        assertNumberOfConditions(for: queryNode, equalTo: 2)
        queryNode.addNode(keypath: \Article.postedAt, compareTo: Date(), comparator: .greaterThanOrEqual, connectWith: .and)
        assertNumberOfConditions(for: queryNode, equalTo: 3)
    }

    func testQuery_2Conditions_And_ExecutesCorrectly() {
        let queryNode = QueryNode(comparator: .greaterThanOrEqual, compareToValue: 100, comparableObject: Article.self, objectKeyPath: \Article.likes)
        queryNode.addNode(keypath: \Article.isStarred, compareTo: true, comparator: .equal, connectWith: .and)
        let validId = UUID().uuidString
        
        let articles: [Article] = [
            Article(id: UUID().uuidString, author: "Author", postedAt: Date(), likes: 100, isStarred: false),
            Article(id: validId, author: "Author", postedAt: Date(), likes: 100, isStarred: true)
        ]
        
        let filteredArticles = articles.evaluate(node: queryNode)
        
        XCTAssertEqual(filteredArticles.count, 1)
        XCTAssertTrue(filteredArticles.allSatisfy({ $0.id == validId}))
    }
    
    func testQuery_3Conditions_AndandOr_ExecutesCorrectly() {
        let currentDate = Date()
        
        let queryNode = QueryNode(comparator: .greaterThanOrEqual, compareToValue: 100, comparableObject: Article.self, objectKeyPath: \Article.likes)
        queryNode.addNode(keypath: \Article.isStarred, compareTo: true, comparator: .equal, connectWith: .and)
        queryNode.addNode(keypath: \Article.postedAt, compareTo: Date(), comparator: .less, connectWith: .or)
        let validId = UUID().uuidString
        
        let articles: [Article] = [
            Article(id: UUID().uuidString, author: "Author", postedAt: Date(), likes: 90, isStarred: false),
            Article(id: UUID().uuidString, author: "Author", postedAt: currentDate, likes: 90, isStarred: true),
            Article(id: validId, author: "Author", postedAt: currentDate, likes: 100, isStarred: false)
        ]
        
        let filteredArticles = articles.evaluate(node: queryNode)
        
        XCTAssertEqual(filteredArticles.count, 1)
        XCTAssertTrue(filteredArticles.allSatisfy({ $0.id == validId}))
    }
}

extension QueryBuilderSwiftUITests {
    func assertNumberOfConditions(for node: AnyQueryNode, equalTo conditions: Int) {
        var startConditions = 1
        var nodeCopy = node
        while nodeCopy.link != nil {
            startConditions += 1
            nodeCopy = nodeCopy.link!.value()
        }
        
        XCTAssertEqual(startConditions, conditions)
    }
}
