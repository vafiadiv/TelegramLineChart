//
//  DataPoint.swift
//  TelegramLineChart
//
//  Created by Valentin Vafiadi
//  Copyright © 2019 VFD. All rights reserved.
//

import Foundation

struct DataPoint {

    typealias DataType = Int

	let x: DataType

	let y: DataType
}

// MARK: -

extension DataPoint: CustomStringConvertible {
	public var description: String {
		return "DataPoint x: \(x), y: \(y)"
	}
}
