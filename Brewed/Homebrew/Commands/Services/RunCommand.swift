//
//  ListCommand.swift
//  Brewed
//
//  Created by Rick Kerkhof on 11/03/2021.
//

import Foundation
import PromiseKit

struct RunServiceCommand: ShellCommandWrapper {
    typealias resultType = Void
    
    let service: Service
    
    func exec() -> Promise<resultType> {
        Shell.exec("/usr/local/bin/brew services run \(service.id)").asVoid()
    }
}
