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
    
    static func urls() -> [URL] {
        var urls = [
            URL(fileURLWithPath: AutostartDirectory.global, isDirectory: true)
        ]
        
        if let local = try? FileManager.default.url(for: .libraryDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
            urls.append(local.appendingPathComponent("LaunchAgents"))
        }
            
        return urls
    }
}

extension Service {
    var startsAtBoot: Bool {
        AutostartDirectory.isGlobalPlist(plist)
    }

    var startsAtLogin: Bool {
        AutostartDirectory.isLocalPlist(plist)
    }
    
    var plistName: String {
        "homebrew.mxcl.\(self.id).plist"
    }
}
