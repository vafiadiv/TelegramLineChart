//
//  NotImplemented.swift
//  TelegramLineChart
//
//  Created by Valentin Vafiadi
//  Copyright © 2019 Valentin Vafiadi. All rights reserved.
//

import Foundation

@inlinable
func notImplemented(file: String = #file, line: Int = #line, function: StaticString = #function) -> Never {
    fatalError("\(file):\(line) \(function) is not implemented")
}