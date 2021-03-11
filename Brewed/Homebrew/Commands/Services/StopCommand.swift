//
//  ListCommand.swift
//  Brewed
//
//  Created by Rick Kerkhof on 11/03/2021.
//

import Foundation
import PromiseKit

struct StopServiceCommand: ShellCommandWrapper {
    typealias resultType = Void
    
    let service: Service
    
    func exec() -> Promise<resultType> {
        Shell.exec("/usr/local/bin/brew services stop \(service.id)").asVoid()
    }
}
