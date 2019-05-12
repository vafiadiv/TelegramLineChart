//
//  BinaryFloatingPoint.swift
//  ArtFit
//
//  Copyright © 2019 VFD. All rights reserved.
//

import Foundation

extension Double {

	var abbreviated: String {
		var num = self

		let sign = ((num < 0) ? "-" : "")
		num = fabs(num)

		if (num < 1000.0) {
			return "\(sign)\(num)"
		}

		let exp: Int = Int(log10(num) / 3.0)
		let units = ["K", "M", "G", "T", "P", "E"]
		let roundedNum: Double = (10 * num / pow(1000.0, Double(exp))).rounded() / 10

		return "\(sign)\(roundedNum)\(units[exp - 1])"
	}
}