//
//  LaunchdPlistRepresentative.swift
//  Brewed
//
//  Created by Rick Kerkhof on 22/03/2021.
//

import Foundation

struct LaunchdPlistRepresentative: Codable {
    let Label: String
    
    let ProgramArguments: [String]
    
    let WorkingDirectory: String
    
    let StandardErrorPath: String?
    let StandardOutputPath: String?
}
