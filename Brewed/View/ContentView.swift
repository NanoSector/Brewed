//
//  ContentView.swift
//  Brewed
//
//  Created by Rick Kerkhof on 11/03/2021.
//

import SwiftUI

struct ContentView: View {
    @StateObject var managedServices = ManagedServices()
    @StateObject var globalAlert = GlobalAlert()

    @State private var showingErrorAlert = false
    var lastError: Error? = nil

    @State private var bogus = false
    @State private var other = true

    @State private var version = ""

    var body: some View {
        VStack {
            if managedServices.services.count <= 0 {
                VStack {
                    if managedServices.refreshing {
                        Text("Refreshing...").font(.title)
                    } else {
                        Text("No services found").font(.title)
                        Text("Check whether Homebrew is set up properly.")
                    }
                }.frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(managedServices.services) {
                        ServiceRow(service: $0).padding(.bottom)
                    }
                }
            }
        }
        .onAppear(perform: {
            VersionCommand().exec().done { version in
                self.version = version.version
                managedServices.refresh()
            }.catch { _ in
                self.version = "N/A"
                globalAlert.show(
                    title: "Homebrew version check failed",
                    body: "Could not gather Homebrew version information. Make sure it is installed properly."
                )
            }
        })
        .alert(isPresented: $globalAlert.shown) {
            Alert(
                title: Text(globalAlert.title),
                message: Text(globalAlert.body),
                dismissButton: .default(Text("OK"))
            )
        }
        .toolbar {
            if managedServices.refreshing {
                ProgressView().controlSize(.small)
            }

            Button(action: {
                managedServices.refresh()
            }) {
                Image(systemName: "arrow.clockwise")
            }
        }
        .navigationSubtitle("Homebrew \(version)")
        .environmentObject(managedServices)
        .environmentObject(globalAlert)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
