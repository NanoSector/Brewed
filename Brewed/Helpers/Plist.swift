//
//  Plist.swift
//  Brewed
//
//  Created by Rick Kerkhof on 14/03/2021.
//

import Foundation

struct Plist {
    static func toMap<K: Hashable, V: Any>(url: URL) throws -> [K: V]? {
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

    static func path(for service: String) -> String? {
        let path = "/usr/local/opt/\(service)/homebrew.mxcl.\(service).plist"
        
        if FileManager.default.fileExists(atPath: path) {
            return path
        }

        return nil
    }
}
