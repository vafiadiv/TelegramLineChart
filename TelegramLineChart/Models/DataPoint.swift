//
//  DataPoint.swift
//  Copyright © 2019 Cleverpumpkin, Ltd. All rights reserved.
//

import Foundation

struct DataPoint {
	let x: Int
	let y: Int
}

extension DataPoint: CustomStringConvertible {
	public var description: String {
		return "DataPoint x: \(x), y: \(y)"
	}
}
