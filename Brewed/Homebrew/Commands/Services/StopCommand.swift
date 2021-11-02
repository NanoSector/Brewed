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
        guard NSRegularExpression.alphanumeric().matches(service.id) else {
            return Promise(error: ProcessError.IllegalArguments)
        }

        return Shell.exec(brew: "services stop \(service.id)").asVoid()
    }
}
