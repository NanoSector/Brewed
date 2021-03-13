//
//  Shell.swift
//  Brewed
//
//  Created by Rick Kerkhof on 12/03/2021.
//

import Foundation
import PromiseKit

struct Shell {
    typealias processResult = (exitCode: Int32, stdout: String, stderr: String)

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
                task.launch()
                task.waitUntilExit()

                guard task.terminationStatus == 0 else {
                    seal.reject(ProcessError.NonZeroExitCode(stderr: stderr.toString()))
                    return
                }

                seal.fulfill((task.terminationStatus, stdout.toString(), stderr.toString()))
            }
        }
    }
}

protocol ShellCommandWrapper {
    associatedtype resultType

    func exec() -> Promise<resultType>
}

extension Pipe {
    func toString() -> String {
        let data = self.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8)!
    }
}

enum ProcessError: Error {
    case NonZeroExitCode(stderr: String)
    case IllegalArguments
}
