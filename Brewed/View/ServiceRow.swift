//
//  ServiceRow.swift
//  Brewed
//
//  Created by Rick Kerkhof on 13/03/2021.
//

import PromiseKit
import SwiftUI

struct ServiceRow: View {
    @EnvironmentObject var managedServices: ManagedServices
    @EnvironmentObject var globalAlert: GlobalAlert
    
    let service: Service
    
    @State private var showingPopover = false
    @State private var executingCommand = false
    
    @State private var showingStartHelpPopover = false
    
    var body: some View {
        HStack {
            Button(action: { showingPopover = true }) {
                Image(systemName: "eye.fill")
            }.popover(isPresented: $showingPopover, arrowEdge: .leading) {
                ServiceInfo(service: service)
            }
            
            VStack(alignment: .leading) {
                Text(service.id)
                
                if service.user != nil {
                    Text("User: \(service.user!)")
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            VStack {
                HStack {
                    if service.status == .stopped {
                        Button(action: run) {
                            Image(systemName: "play")
                            Text("Run")
                        }
                        Button(action: start) {
                            Image(systemName: "play.fill")
                            Text("Start")
                        }.onHover { hovering in
                            showingStartHelpPopover = hovering
                        }.popover(isPresented: $showingStartHelpPopover, arrowEdge: .bottom) {
                            Text("This will run the service now and when logging in as the current user.").padding()
                        }
                    }
                    
                    if service.status == .started {
                        Button(action: stop) {
                            Image(systemName: "stop.fill")
                            Text("Stop")
                        }
                        Button(action: restart) {
                            Image(systemName: "arrow.clockwise")
                            Text("Restart")
                        }
                    }
                }
            }
        }.disabled(executingCommand)
    }
    
    func run() {
        handleRefresh(service.run())
    }
    
    func start() {
        handleRefresh(service.start())
    }
    
    func stop() {
        handleRefresh(service.stop())
    }
    
    func restart() {
        handleRefresh(service.restart())
    }
    
    func handleRefresh(_ promise: Promise<Service>) {
        executingCommand = true
        
        DispatchQueue.global(qos: .background).async {
            promise.done(on: .main) { service in
                managedServices.update(service: service)
                managedServices.refresh()
            }.ensure(on: .main) {
                executingCommand = false
            }.catch(on: .main) { _ in
                globalAlert.show(title: "Operation failed", body: "Could not change state of the service.")
            }
        }
    }
}

struct ServiceRow_Previews: PreviewProvider {
    static var previews: some View {
        ServiceRow(service: Service(id: "test", status: .started, user: "user", plist: nil))
        ServiceRow(service: Service(id: "test", status: .stopped, user: nil, plist: nil))
    }
}
