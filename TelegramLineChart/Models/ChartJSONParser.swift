//
//  ChartJSONParser.swift
//  Copyright © 2019 Cleverpumpkin, Ltd. All rights reserved.
//

import Foundation

struct ChartJSONParser {
	static func charts(from JSON: Data) throws -> [Chart<Int, Int>]  {

		let decoder = JSONDecoder()
		let chartDTOs = try decoder.decode([ChartDTO].self, from: JSON)

		return [Chart(lines: [])]
	}
}
