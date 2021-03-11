//
//  ListCommand.swift
//  Brewed
//
//  Created by Rick Kerkhof on 11/03/2021.
//

import Foundation
import PromiseKit

struct ListServicesCommand: ShellCommandWrapper {
    typealias resultType = [Service]
    
    let regex = try! NSRegularExpression(pattern: "\\S+")
    
    func exec() -> Promise<resultType> {
        Promise { seal in
            Shell.exec("/usr/local/bin/brew services list").done { _, output, _ in
                var commands = output.split(whereSeparator: \.isNewline)
                commands.remove(at: 0)
            
                var result: [Service] = []
            
                for command in commands {
                    let parts = regex.matches(in: String(command))
                    
                    let name = parts[0]
                    let status = parts[1]
                    let user = parts[safe: 2]
                    let plist = parts[safe: 3]
                
                    result.append(Service(
                        id: name,
                        status: ServiceStatus(rawValue: status)!,
                        user: user,
                        plist: (plist != nil) ? URL(fileURLWithPath: plist!, isDirectory: false) : nil
                    ))
                }
            
                seal.fulfill(result)
            }.catch(seal.reject)
        }
    }
}
