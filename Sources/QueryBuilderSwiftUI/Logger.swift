//
//  Logger.swift
//  
//
//  Created by Shyam Kumar on 3/31/23.
//

import Foundation

class Logger {
    enum Severity: String {
        case info = "ℹ️"
        case warning = "⚠️"
        case error = "❗️"
    }
    
    static func log(
        _ str: String,
        severity: Severity,
        file: String = #file,
        line: Int = #line
    ) {
        print(
            """
            \(severity.rawValue) \(str)
            Line \(line) of \(file)
            """
        )
    }
}
