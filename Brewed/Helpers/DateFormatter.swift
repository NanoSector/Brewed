//
//  DateFormatter.swift
//  Brewed
//
//  Created by Rick Kerkhof on 14/03/2021.
//

import Foundation
import SwiftUI

extension Date {
    func format() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short

        return formatter.string(from: self)
    }
}
