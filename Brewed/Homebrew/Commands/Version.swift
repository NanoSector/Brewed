//
//  ListCommand.swift
//  Brewed
//
//  Created by Rick Kerkhof on 11/03/2021.
//

import Foundation
import PromiseKit

struct VersionCommand: ShellCommandWrapper {
    typealias resultType = HomebrewVersion
    
    let regex = try! NSRegularExpression(pattern: "\\S+")
    
    func exec() -> Promise<resultType> {
        Promise { seal in
            Shell.exec(brew: "-v").done { _, output, _ in
                var commands = output.split(whereSeparator: \.isNewline)
                
                let versionString = String(commands[0].split(separator: " ")[1])
                var version = HomebrewVersion(version: versionString)
                commands.remove(at: 0)
                
                commands.forEach { tap in
                    version.taps.append(String(tap))
                }
            
                seal.fulfill(version)
            }.catch(seal.reject)
        }
    }
}
