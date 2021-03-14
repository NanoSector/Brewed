//
//  ServiceInfo.swift
//  Brewed
//
//  Created by Rick Kerkhof on 13/03/2021.
//

import SwiftUI

struct ServiceInfo: View {
    @EnvironmentObject var managedServices: ManagedServices

    let service: Service

    @State private var runsAtBoot = false
    @State private var runsAtLogin = false

    var body: some View {
        VStack(alignment: .leading) {
            Text(service.id).font(.title)

            Toggle("Runs at boot", isOn: $runsAtBoot).disabled(true)
            Toggle("Runs at login", isOn: $runsAtLogin).disabled(true)

            if let plist = service.plist {
                Text("Launch plist").font(.headline)
                Link(plist.path, destination: plist)
            }

            if let logs = service.logPaths() {
                Text("Log files").font(.headline)

                ForEach(logs, id: \.self) { log in
                    Link(log.path, destination: log)
                }
            }
        }.onAppear {
            runsAtBoot = service.startsAtBoot
            runsAtLogin = service.startsAtLogin
        }.padding()
    }
}

struct ServiceInfo_Previews: PreviewProvider {
    static var previews: some View {
        ServiceInfo(service: Service(id: "test", status: .started, user: "user", plist: nil))
        ServiceInfo(service: Service(id: "test", status: .stopped, user: nil, plist: nil))
    }
}
