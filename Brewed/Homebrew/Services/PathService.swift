//
//  HomebrewPathService.swift
//  Brewed
//
//  Created by Rick Kerkhof on 02/11/2021.
//

import Foundation

struct PathService {
    // https://stackoverflow.com/questions/69624731/programmatically-detect-apple-silicon-vs-intel-cpu-in-a-mac-app-at-runtime
    static func GetMachineHardwareName() -> String? {
        var sysInfo = utsname()
        let retVal = uname(&sysInfo)

        guard retVal == EXIT_SUCCESS else { return nil }

        return String(cString: &sysInfo.machine.0, encoding: .utf8)
    }
    
    static func GetHomebrewBasePath() -> String {
        let machineHardware = GetMachineHardwareName()
        
        if (machineHardware == nil || machineHardware == "x86_64") {
            return "/usr/local"
        }
        
        return "/opt/homebrew"
    }
}
