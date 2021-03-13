//
//  ManagedServices.swift
//  Brewed
//
//  Created by Rick Kerkhof on 12/03/2021.
//

import Foundation
import os

class ManagedServices: ObservableObject, FileMonitorDelegate, FolderMonitorDelegate {
    @Published var services: [Service] = []
    
    @Published var refreshing = false
    
    private var monitors: [URL: FilesystemMonitor] = [:]
    
    let logger = Logger(subsystem: "nl.nanosector.Brewed.ManagedServices", category: "Service management")

    func refresh() {
        logger.debug("Refresh triggered.")
        
        refreshing = true
        ListServicesCommand().exec()
            .done { services in
                self.monitors.forEach { $0.value.stop() }
                self.monitors.removeAll()
                
                self.services = services
                self.logger.debug("Refresh done; got \(services.count) services")
                
                AutostartDirectory.urls().forEach { url in
                    if let monitor = try? FolderMonitor(url: url) {
                        self.logger.debug("Registering FolderMonitor for \(url.absoluteString)")
                        self.monitors[url] = monitor
                        monitor.delegate = self
                    }
                }
                
                self.services.forEach { service in
                    guard let plist = service.plist else {
                        return
                    }
                    
                    if let monitor = try? FileMonitor(url: plist) {
                        self.logger.debug("Registering FileMonitor for \(plist.absoluteString)")
                        self.monitors[plist] = monitor
                        monitor.delegate = self
                    }
                }
            }.ensure {
                self.refreshing = false
            }.cauterize()
    }
    
    func fileEvent(url: URL, event: DispatchSource.FileSystemEvent) {
        self.logger.debug("Got file event.")
        DispatchQueue.main.async {
            self.refresh()
        }
    }
    
    func folderEvent(url: URL, event: DispatchSource.FileSystemEvent, additions: [URL]) {
        let wantedPlistNames = services.map { $0.plistName }
        self.logger.debug("Got directory event.")
        
        if !additions.contains(where: { wantedPlistNames.contains($0.lastPathComponent) }) {
            self.logger.debug("Dropping directory event; additions list does not contain a wanted file.")
            return
        }
        
        DispatchQueue.main.async {
            self.refresh()
        }
    }
}
