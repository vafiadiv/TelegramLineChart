//
//  Date.swift
//  TelegramLineChart
//
//  Created by Valentin Vafiadi
//  Copyright © 2019 VFD. All rights reserved.
//

import Foundation

extension Date {

    init(dataPointX: DataPoint.DataType) {
        self.init(timeIntervalSince1970: TimeInterval(dataPointX / 1000))
    }
}