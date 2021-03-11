//
//  AutostartService.swift
//  Brewed
//
//  Created by Rick Kerkhof on 12/03/2021.
//

import Foundation

struct AutostartDirectory {
    static let global = "/Library/LaunchDaemons"
    static let local = "/Users/[^\\/]+/Library/LaunchAgents/.+"
    
    static func isGlobalPlist(_ url: URL?) -> Bool {
        url?.deletingLastPathComponent() == URL(fileURLWithPath: AutostartDirectory.global, isDirectory: true)
    }
    
    static func isLocalPlist(_ url: URL?) -> Bool {
        let regex = try? NSRegularExpression(pattern: AutostartDirectory.local, options: [])
        
        return regex?.matches(url?.absoluteString ?? "") ?? false
    }
}

extension Service {
    var startsAtBoot: Bool {
        AutostartDirectory.isGlobalPlist(plist)
    }

    var startsAtLogin: Bool {
        AutostartDirectory.isLocalPlist(plist)
    }
}
