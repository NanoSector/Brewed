//
//  LogsService.swift
//  Brewed
//
//  Created by Rick Kerkhof on 14/03/2021.
//

import Foundation
import os
import SwiftUI

struct LogsService {
    static let shared = LogsService()

    let logPaths: [String: [URL]]

    let logger = Logger(subsystem: "nl.nanosector.Brewed.LogService", category: "Service logs")

    init() {
        guard let mappingsPath = Bundle.main.url(forResource: "LogMappings", withExtension: "plist"),
              let plistContents: [String: [String]] = try? Plist.toMap(url: mappingsPath)
        else {
            logger.warning("Could not read mappings Plist; proceeding without mappings. No logs will be available.")
            logPaths = [:]
            return
        }

        let transformed = plistContents.mapValues { pathList in
            pathList.map { path in
                URL(fileURLWithPath: path)
            }
        }

        logger.debug("Found logs for \(transformed.count) services")
        logPaths = transformed
    }

    func paths(for string: String) -> [URL]? {
        guard logPaths.contains(where: { $0.key == string }),
              let paths = logPaths[string]
        else {
            return nil
        }

        return paths
    }
}

extension Service {
    func logPaths() -> [URL]? {
        var servicePaths = LogsService.shared.paths(for: id) ?? []
        
        if let launchd = self.deserializePlist() {
            if let stderr = launchd.StandardErrorPath {
                servicePaths.append(URL(fileURLWithPath: stderr))
            }
            if let stdout = launchd.StandardOutputPath, stdout != launchd.StandardErrorPath {
                servicePaths.append(URL(fileURLWithPath: stdout))
            }
        }
        
        guard servicePaths.count > 0 else {
            return nil
        }
        
        return servicePaths
    }
}

// This thing is messy.
class LogWatcher: ObservableObject, FileMonitorDelegate {
    @Published var contents: String = ""
    @Published var contentsPerLine: [String] = []
    @Published var lastChanged = Date(timeIntervalSince1970: .zero)

    var watchedLogFile: LogFile?

    func watch(log path: URL) -> LogWatcher {
        watchedLogFile = try? LogFile(from: path, delegate: self)
        refresh()
        return self
    }

    func refresh() {
        if let contents = try? watchedLogFile?.contents(),
           let attr = try? FileManager.default.attributesOfItem(atPath: watchedLogFile!.path.path),
           let modifiedDate = attr[FileAttributeKey.modificationDate] as? Date
        {
            self.contents = contents
            contentsPerLine = contents.split(whereSeparator: \.isNewline).map { String($0) }
            lastChanged = modifiedDate
        }
    }

    func fileEvent(url _: URL, event _: DispatchSource.FileSystemEvent) {
        refresh()
    }
}

extension String {
    func logColor() -> Color? {
        if lowercased().contains("notice") {
            return .blue
        }

        if lowercased().contains("warn") {
            return .yellow
        }

        if lowercased().contains("err") {
            return .red
        }

        return nil
    }
}
