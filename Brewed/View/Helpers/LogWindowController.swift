//
//  LogWindowController.swift
//  Brewed
//
//  Created by Rick Kerkhof on 14/03/2021.
//

import Foundation

import SwiftUI

class LogWindowController<RootView: View>: NSWindowController {
    convenience init(rootView: RootView) {
        let hostingController = NSHostingController(
            rootView: rootView.frame(
                minWidth: 600,
                minHeight: 300
            )
        )
        let window = NSWindow(contentViewController: hostingController)
        self.init(window: window)
    }
}
