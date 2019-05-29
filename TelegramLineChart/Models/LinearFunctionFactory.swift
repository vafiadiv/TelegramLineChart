//
//  LinearFunctionFactory.swift
//  TelegramLineChart
//
//  Created by Valentin Vafiadi
//  Copyright © 2019 VFD. All rights reserved.
//

import Foundation

struct LinearFunctionFactory<T: BinaryFloatingPoint> {

    //Returns linear function f(x) = k * x + b that contains points (x1, y1) and (x2, y2)
    func function(x1: T, y1: T, x2: T, y2: T) -> ((T) -> T) {
        return { x in
            let k = (y2 - y1) / (x2 - x1)
            let b = y1 - k * x1
            return k * x + b
        }
    }
}
