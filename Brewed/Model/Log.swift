//
//  Log.swift
//  Brewed
//
//  Created by Rick Kerkhof on 14/03/2021.
//

import Foundation

struct LogFile {
    let path: URL

    var monitor: FileMonitor?
    var delegate: FileMonitorDelegate?

    init(from url: URL) throws {
        path = url
    }

    init(from url: URL, delegate: FileMonitorDelegate) throws {
        try self.init(from: url)
        self.delegate = delegate

        monitor = try FileMonitor(url: url)
        monitor?.delegate = delegate
    }

    func contents() throws -> String {
        try String(contentsOf: path)
    }
}
