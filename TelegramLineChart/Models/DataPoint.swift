//
//  DataPoint.swift
//  Copyright © 2019 Cleverpumpkin, Ltd. All rights reserved.
//

import Foundation

struct DataPoint {

    typealias XType = Int
    typealias YType = Int

	let x: XType
	let y: YType
}

// MARK: -

extension DataPoint: CustomStringConvertible {
	public var description: String {
		return "DataPoint x: \(x), y: \(y)"
	}
}
