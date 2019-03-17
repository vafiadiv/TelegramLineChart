//
//  DataLine.swift
//  Copyright © 2019 Cleverpumpkin, Ltd. All rights reserved.
//

import Foundation
import UIKit.UIColor

struct DataLine<XType, YType> {
	let points: [DataPoint<XType, YType>]
	let color: UIColor
	let name: String
}
