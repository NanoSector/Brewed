//
//  GlobalAlert.swift
//  Brewed
//
//  Created by Rick Kerkhof on 13/03/2021.
//

import Foundation

class GlobalAlert: ObservableObject {
    @Published var shown = false
    var title = ""
    var body = ""

    func show(title: String, body: String) {
        self.title = title
        self.body = body
        shown = true
    }

    func dismiss() {
        shown = false
    }
}
