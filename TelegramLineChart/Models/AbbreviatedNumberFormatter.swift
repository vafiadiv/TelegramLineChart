//
//  BinaryFloatingPoint.swift
//  TelegramLineChart
//
//  Created by Valentin Vafiadi
//  Copyright © 2019 Valentin Vafiadi. All rights reserved.
//

import Foundation

///
///Converts a big number into a short and readable format: 12345 -> "12.3K", 1_000_000 -> "1M", -1 etc.
/// - Note: Conversion from short-formatted string to number is not implemented
class AbbreviatedNumberFormatter: NumberFormatter {

    override init() {
        super.init()
        self.maximumFractionDigits = 1
    }

    required init?(coder aDecoder: NSCoder) {
        notImplemented()
    }

    override func string(from number: NSNumber) -> String? {
        let doubleNumber = number.doubleValue

        let absNumber = fabs(doubleNumber)

        if (absNumber < 1000.0) {
            return super.string(from: number)
        }

        let exp: Int = Int(log10(absNumber) / 3.0)
        let units = ["K", "M", "G", "T", "P", "E"]
        let roundedNum: Double = doubleNumber / pow(1000.0, Double(exp))

        let roundedNumString = super.string(from: NSNumber(floatLiteral: roundedNum)) ?? String(roundedNum)
        return "\(roundedNumString)\(units[exp - 1])"
    }
}
