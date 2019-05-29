//
//  DataPoint.swift
//  Copyright © 2019 Cleverpumpkin, Ltd. All rights reserved.
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
