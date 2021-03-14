//
//  DateFormatter.swift
//  Brewed
//
//  Created by Rick Kerkhof on 14/03/2021.
//

import Foundation
import SwiftUI

extension Date {
    func format(date: DateFormatter.Style, time: DateFormatter.Style) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = date
        formatter.timeStyle = time

        return formatter.string(from: self)
    }
}
