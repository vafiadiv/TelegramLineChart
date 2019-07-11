//
//  DataLine.swift
//  TelegramLineChart
//
//  Created by Valentin Vafiadi
//  Copyright © 2019 Valentin Vafiadi. All rights reserved.
//

import Foundation
import UIKit.UIColor

struct DataLine {

    var points: [DataPoint]
    let color: UIColor
    let name: String
}

// MARK: - Convenience extensions

extension Array where Element == DataLine {

    var xRange: ClosedRange<DataPoint.DataType> {

        let firstPoints = self.compactMap { $0.points.first?.x }

        let lastPoints = self.compactMap { $0.points.last?.x }

        let minX = firstPoints.min() ?? 0
        let maxX = lastPoints.max() ?? minX

        return minX...maxX
    }
}

// MARK: - mocked data

extension DataLine {

    static var mockDataLine1: DataLine {
        let mockPoints = [
            DataPoint(x: 0, y: 5),
            DataPoint(x: 5, y: 10),
            DataPoint(x: 10, y: 5),
            DataPoint(x: 15, y: 10),
            DataPoint(x: 20, y: 5),
            DataPoint(x: 25, y: 10),
            DataPoint(x: 30, y: 5),
            DataPoint(x: 35, y: 10),
            DataPoint(x: 40, y: 333),
            DataPoint(x: 40, y: 10),
        ]
        return DataLine(points: mockPoints, color: .green, name: "Line")
    }

    static var mockDataLine2: DataLine {

        let millisecondsInDay = 1000 * 60 * 60 * 24

        let mockPoints = [
            DataPoint(x: millisecondsInDay * 0, y: 5),
            DataPoint(x: millisecondsInDay * 1, y: 10),
            DataPoint(x: millisecondsInDay * 2, y: 5),
            DataPoint(x: millisecondsInDay * 4, y: 10),
            DataPoint(x: millisecondsInDay * 6, y: 5),
            DataPoint(x: millisecondsInDay * 10, y: 10),
            DataPoint(x: millisecondsInDay * 30, y: 5),
            DataPoint(x: millisecondsInDay * 35, y: 10),
            DataPoint(x: millisecondsInDay * 40, y: 333),
            DataPoint(x: millisecondsInDay * 40, y: 10),
        ]
        return DataLine(points: mockPoints, color: .green, name: "Line")
    }
}
