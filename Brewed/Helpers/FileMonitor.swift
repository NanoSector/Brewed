//
//  FileMonitor.swift
//  Brewed
//
//  Created by Rick Kerkhof on 13/03/2021.
//
//  Code found from https://swiftrocks.com/dispatchsource-detecting-changes-in-files-and-folders-in-swift
//  and altered.
//

import Foundation
import os

protocol FileMonitorDelegate: AnyObject {
    func fileEvent(url: URL, event: DispatchSource.FileSystemEvent)
}

final class FileMonitor: FilesystemMonitor {
    let url: URL
    let logger = Logger(subsystem: "nl.nanosector.Brewed.FileMonitor", category: "File monitoring")

    let fileHandle: FileHandle
    let source: DispatchSourceFileSystemObject

    weak var delegate: FileMonitorDelegate?

    init(url: URL) throws {
        self.url = url
        fileHandle = try FileHandle(forReadingFrom: url)

        source = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: fileHandle.fileDescriptor,
            eventMask: [.write, .delete],
            queue: DispatchQueue.main
        )

        source.setEventHandler {
            let event = self.source.data
            self.logger.log(level: .info, "Change detected; FileSystemEvent \(event.rawValue), URL \(url.absoluteString)")
            self.delegate?.fileEvent(url: url, event: event)
        }

        source.setCancelHandler {
            try? self.fileHandle.close()
        }

        source.resume()
        logger.debug("Init for \(url.absoluteString)")
    }

    func stop() {
        delegate = nil
        source.cancel()
    }

    deinit {
        stop()
        logger.debug("Deinit for \(self.url.absoluteString)")
    }
}
