//
//  ServiceLogs.swift
//  Brewed
//
//  Created by Rick Kerkhof on 14/03/2021.
//

import SwiftUI

struct ServiceLogs: View {
    let service: Service

    var body: some View {
        NavigationView {
            List {
                if let logs = service.logPaths() {
                    ForEach(logs, id: \.absoluteString) { url in
                        VStack {
                            NavigationLink(url.path, destination: LogView(watcher: LogWatcher().watch(log: url)))
                            Button(action: {
                                NSWorkspace.shared.activateFileViewerSelecting([url])
                            }) { Text("Show in Finder") }
                        }.disabled(!FileManager.default.fileExists(atPath: url.path))
                    }
                } else {
                    Text("No log files found!").font(.callout)
                }
            }
        }
    }
}

struct ServiceLogs_Previews: PreviewProvider {
    static var previews: some View {
        ServiceLogs(service: Service(id: "php", status: .stopped, user: nil, plist: nil))
    }
}
