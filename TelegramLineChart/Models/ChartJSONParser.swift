//
//  ChartJSONParser.swift
//  Copyright © 2019 Cleverpumpkin, Ltd. All rights reserved.
//

import Foundation

struct ChartJSONParser {
	static func chart<XType, YType>(from JSON: Data) throws -> Chart<XType, YType>?  {

		let decoder = JSONDecoder()
		let _ = decoder.userInfo
		return nil
	}
}
