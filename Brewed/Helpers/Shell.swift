//
//  Shell.swift
//  Brewed
//
//  Created by Rick Kerkhof on 12/03/2021.
//

import Foundation
import os
import PromiseKit

struct Shell {
    typealias processResult = (exitCode: Int32, stdout: String, stderr: String)

    static let logger = Logger(subsystem: "nl.nanosector.Brewed.Shell", category: "Shell")

    static func exec(_ command: String) -> Promise<processResult> {
        Promise { seal in
            let task = Process()
            let stdout = Pipe()
            let stderr = Pipe()

            task.standardOutput = stdout
            task.standardError = stderr
            task.arguments = ["-c", command]
            task.launchPath = "/bin/zsh"

            DispatchQueue.global(qos: .background).async {
                TimeLogger.logTime(logger: self.logger) {
                    task.launch()
                    logger.debug("Task with PID \(task.processIdentifier) started: \(task.launchPath!) \(task.arguments!.joined(separator: " "))")

                    task.waitUntilExit()
                    logger.debug("Task with PID \(task.processIdentifier) exited with code \(task.terminationStatus)")
                }

                guard task.terminationStatus == 0 else {
                    logger.debug("Task failed with non-zero exit code; rejecting promise")
                    seal.reject(ProcessError.NonZeroExitCode(stderr: stderr.toString()))
                    return
                }

                logger.debug("Task succeeded; fulfilling promise")
                seal.fulfill((task.terminationStatus, stdout.toString(), stderr.toString()))
            }
        }
    }
    
    static func exec(brew command: String) -> Promise<processResult> {
        let brew = "\(PathService.GetHomebrewBasePath())/bin/brew"
        
        return exec("\(brew) \(command)")
    }
}

protocol ShellCommandWrapper {
    associatedtype resultType

    func exec() -> Promise<resultType>
}

extension Pipe {
    func toString() -> String {
        let data = fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8)!
    }
}

enum ProcessError: Error {
    case NonZeroExitCode(stderr: String)
    case IllegalArguments
}
