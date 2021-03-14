//
//  Plist.swift
//  Brewed
//
//  Created by Rick Kerkhof on 14/03/2021.
//

import Foundation

struct Plist {
    static func deserialise<K: Hashable, V: Any>(url: URL) throws -> [K: V]? {
        let infoPlistData = try Data(contentsOf: url)

        guard let dict = try PropertyListSerialization.propertyList(
            from: infoPlistData,
            options: [],
            format: nil
        ) as? [K: V]
        else {
            return nil
        }

        return dict
    }
}
