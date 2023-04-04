//
//  RelativeDate.swift
//  
//
//  Created by Shyam Kumar on 4/4/23.
//

import Foundation

public enum RelativeDate: String, Codable, CaseIterable {
    case today = "Today"
    case yesterday = "Yesterday"
    case oneWeekAgo = "One week ago"
    case oneMonthAgo = "One month ago"
    case oneYearAgo = "One year ago"
    
    var date: Date? {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        switch self {
        case .today:
            return today
        case .yesterday:
            return calendar.date(byAdding: .day, value: -1, to: today)
        case .oneWeekAgo:
            return calendar.date(byAdding: .weekOfYear, value: -1, to: today)
        case .oneMonthAgo:
            return calendar.date(byAdding: .month, value: -1, to: today)
        case .oneYearAgo:
            return calendar.date(byAdding: .year, value: -1, to: today)
        }
    }
}

public enum ComparableDate: IsComparable, Equatable {
    case date(Date)
    case relativeDate(RelativeDate)
    
    // MARK: - IsComparable
    public func evaluate(comparator: Comparator, against value: any IsComparable) -> Bool {
        guard let value = value as? Date else {
            Logger.log("Value \(value) passed into `evaluate` is not a Date, returning false", severity: .error)
            return false
        }
        
        switch self {
        case .date(let date):
            return value.evaluate(comparator: comparator, against: date)
        case .relativeDate(let relativeDate):
            guard let date = relativeDate.date else {
                Logger.log("Unable to get date from relative date \(relativeDate), returning false", severity: .error)
                return false
            }
            return value.evaluate(comparator: comparator, against: date)
        }
    }
    
    public static func createAssociatedViewModel(options: [(any IsComparable)], startingValue: (any IsComparable)?) -> DateComparableViewModel {
        DateComparableViewModel(value: startingValue as? ComparableDate)
    }
}
