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

protocol FolderMonitorDelegate: AnyObject {
    func folderEvent(url: URL, event: DispatchSource.FileSystemEvent, additions: [URL])
}

protocol FilesystemMonitor {}

final class FolderMonitor: FilesystemMonitor {
    let url: URL
    
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
            self.delegate?.folderEvent(
                url: url,
                event: event,
                additions: contents.filter { !oldContents.contains($0) }
            )
        }
        
        source.setCancelHandler {
            close(self.fileHandle)
        }
        
        source.resume()
    }
    
    deinit {
        source.cancel()
    }
}
