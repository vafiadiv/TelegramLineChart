//
//  DataLine.swift
//  Copyright © 2019 Cleverpumpkin, Ltd. All rights reserved.
//

import Foundation
import UIKit.UIColor

struct DataLine {
	let points: [DataPoint]
	let color: UIColor
	let name: String
}

// MARK: - mocked data

extension DataLine {

    static var mockDataLine1: DataLine {
        let mockPoints = [
            DataPoint(x: 0, y: 0),
            DataPoint(x: 5, y: 10),
            DataPoint(x: 10, y: 5),
            DataPoint(x: 15, y: 15),
            DataPoint(x: 20, y: 15),
        ]
        return DataLine(points: mockPoints, color: .green, name: "Line")
    }
}
