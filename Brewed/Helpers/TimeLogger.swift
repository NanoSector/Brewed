//
//  TimeLogger.swift
//  Brewed
//
//  Created by Rick Kerkhof on 13/03/2021.
//

import Foundation
import os

struct TimeLogger {
    static func logTime<T>(logger: Logger, body: () -> T) -> T {
        let start = DispatchTime.now()
        let result = body()
        let end = DispatchTime.now()

        let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds // <<<<< Difference in nano seconds (UInt64)
        let timeInterval = Double(nanoTime) / 1_000_000_000
        logger.debug("Took \(timeInterval) seconds.")

        if timeInterval >= 3 {
            logger.warning("!!! Slow task detected: \(timeInterval) seconds. Please check debug output for specifics.")
        }

        return result
    }
}
