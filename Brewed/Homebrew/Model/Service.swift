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

    func refresh() -> Promise<Service?> {
        Promise { seal in
            ListServicesCommand().exec()
                .done { services in
                    seal.fulfill(services.first { $0.id == self.id })
                }.catch(seal.reject)
        }
    }
    
    func run() -> Promise<Service> {
        Promise { seal in
            RunServiceCommand(service: self).exec()
                .then {
                    self.refresh()
                }
                .done { service in
                    guard let service = service else {
                        throw ServiceError.UnexpectedServiceStatus
                    }
                    
                    seal.fulfill(service)
                }.catch(seal.reject)
        }
    }

    func start() -> Promise<Service> {
        Promise { seal in
            StartServiceCommand(service: self).exec()
                .then {
                    self.refresh()
                }
                .done { service in
                    guard let service = service else {
                        throw ServiceError.UnexpectedServiceStatus
                    }
                    
                    seal.fulfill(service)
                }.catch(seal.reject)
        }
    }
    
    func stop() -> Promise<Service> {
        Promise { seal in
            StopServiceCommand(service: self).exec()
                .then {
                    self.refresh()
                }
                .done { service in
                    guard let service = service else {
                        throw ServiceError.UnexpectedServiceStatus
                    }
                    
                    seal.fulfill(service)
                }.catch(seal.reject)
        }
    }
    
    func restart() -> Promise<Service> {
        Promise { seal in
            StartServiceCommand(service: self).exec()
                .then {
                    self.refresh()
                }
                .done { service in
                    guard let service = service else {
                        throw ServiceError.UnexpectedServiceStatus
                    }
                    
                    seal.fulfill(service)
                }.catch(seal.reject)
        }
    }
}

enum ServiceStatus: String {
    case stopped
    case started
}

enum ServiceError: Error {
    case UnexpectedServiceStatus
}
