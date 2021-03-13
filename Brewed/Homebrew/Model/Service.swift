//
//  Service.swift
//  Brewed
//
//  Created by Rick Kerkhof on 12/03/2021.
//

import Foundation
import PromiseKit

struct Service: Identifiable {
    var id: String
    let status: ServiceStatus
    let user: String?
    let plist: URL?

    func run() -> Promise<Void> {
        RunServiceCommand(service: self).exec().asVoid()
    }

    func start() -> Promise<Void> {
        StartServiceCommand(service: self).exec().asVoid()
    }

    func stop() -> Promise<Void> {
        StopServiceCommand(service: self).exec().asVoid()
    }

    func restart() -> Promise<Void> {
        RestartServiceCommand(service: self).exec().asVoid()
    }
}

enum ServiceStatus: String {
    case stopped
    case started
}

enum ServiceError: Error {
    case UnexpectedServiceStatus
}
