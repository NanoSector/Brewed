//
//  FolderMonitor.swift
//  Brewed
//
//  Created by Rick Kerkhof on 13/03/2021.
//
//  Code found from https://swiftrocks.com/dispatchsource-detecting-changes-in-files-and-folders-in-swift
//  and altered.
//

import Foundation
import os

protocol FolderMonitorDelegate: AnyObject {
    func folderEvent(url: URL, event: DispatchSource.FileSystemEvent, additions: [URL])
}

protocol FilesystemMonitor {
    func stop()
}

final class FolderMonitor: FilesystemMonitor {
    let url: URL
    let logger = Logger(subsystem: "nl.nanosector.Brewed.FolderMonitor", category: "Folder monitoring")

    let fileHandle: Int32
    let source: DispatchSourceFileSystemObject

    weak var delegate: FolderMonitorDelegate?

    init(url: URL) throws {
        self.url = url
        fileHandle = open(url.path, O_EVTONLY)

        source = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: fileHandle,
            eventMask: .write,
            queue: DispatchQueue.main
        )

        var contents = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)

        source.setEventHandler {
            let event = self.source.data

            let oldContents = contents
            contents = try! FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)

            let additions = contents.filter { !oldContents.contains($0) }

            if additions.count <= 0 {
                self.logger.debug("Change detected but no additions found; skipping. FileSystemEvent \(event.rawValue), URL \(url.absoluteString)")
                return
            }

            self.logger.log(level: .info, "Change detected; FileSystemEvent \(event.rawValue), URL \(url.absoluteString)")

            self.delegate?.folderEvent(
                url: url,
                event: event,
                additions: additions
            )
        }

        source.setCancelHandler {
            close(self.fileHandle)
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
