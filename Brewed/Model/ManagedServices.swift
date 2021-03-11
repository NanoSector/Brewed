//
//  ManagedServices.swift
//  Brewed
//
//  Created by Rick Kerkhof on 12/03/2021.
//

import Foundation

class ManagedServices: ObservableObject, FileMonitorDelegate {
    
    @Published var services: [Service] = []
    
    private var monitors: [URL: FileMonitor] = [:]

    func update(service: Service) {
        var services = self.services
        
        guard let index = services.firstIndex(where: { $0.id == service.id }) else {
            services.append(service)
            return
        }
        
        services[index] = service
        self.services = services
    }

    func refresh() {
        ListServicesCommand().exec()
            .done { services in
                self.monitors.removeAll()
                
                self.services = services
                self.services.forEach { service in
                    guard let plist = service.plist else {
                        return
                    }
                    
                    if let monitor = try? FileMonitor(url: plist) {
                        self.monitors[plist] = monitor
                        monitor.delegate = self
                    }
                }
            }.cauterize()
    }
    
    func deleted(url: URL, event: DispatchSource.FileSystemEvent) {
        DispatchQueue.main.async {
            self.refresh()
        }
    }
}
