//
//  LinearFunctionFactory.swift
//  TelegramLineChart
//
//  Created by Valentin Vafiadi
//  Copyright © 2019 VFD. All rights reserved.
//

import Foundation

struct LinearFunctionFactory {
    //Returns linear function f(x) = k * x + b that contains points (x1, y1) and (x2, y2)
    func function(x1: Double, y1: Double, x2: Double, y2: Double) -> ((Double) -> Double) {
        return { x in
            let k = (y2 - y1) / (x2 - x1)
            let b = y1 - k * x1
            return k * x + b
        }
    }
}
