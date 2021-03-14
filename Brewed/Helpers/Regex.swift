//
//  Regex.swift
//  Brewed
//
//  Created by Rick Kerkhof on 12/03/2021.
//

import Foundation

extension NSRegularExpression {
    func matches(_ text: String) -> Bool {
        firstMatch(in: text, range: text.range()) != nil
    }

    func matches(in text: String) -> [String] {
        let results = matches(
            in: text,
            range: text.range()
        )
        return results.map {
            String(text[Range($0.range, in: text)!])
        }
    }

    static func alphanumeric() -> NSRegularExpression {
        try! NSRegularExpression(pattern: "[a-zA-Z0-9]+", options: [])
    }
}

extension String {
    func range() -> NSRange {
        NSRange(startIndex..., in: self)
    }
}
