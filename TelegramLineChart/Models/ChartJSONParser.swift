//
//  ChartJSONParser.swift
//  Copyright © 2019 Cleverpumpkin, Ltd. All rights reserved.
//

import Foundation

struct ChartJSONParser {

	static func charts(from JSON: Data) throws -> [Chart] {

		let decoder = JSONDecoder()
		let chartDTOs = try decoder.decode([ChartDTO].self, from: JSON)

		return try chartDTOs.map { try Chart(DTO: $0) }
	}
}

private extension Chart {

	init(DTO: ChartDTO) throws {
		guard let xColumnName = (DTO.types.first { _, value in value == "x" }?.key),
			  let xColumn = DTO.columns[xColumnName] else {
			throw DecodingError.general("Error finding \"x\" column")
		}

		var lines = [DataLine]()
		//1 column is "x"
		lines.reserveCapacity(DTO.columns.count - 1)

		for (key, column) in DTO.columns {
			//looking only for "line" columns
			if DTO.types[key] != "line" {
				continue
			}

			var points = [DataPoint]()
			points.reserveCapacity(xColumn.count)

			for i in 0..<column.count {
				let yValue = column[i]
				let xValue = xColumn[i]
				points.append(DataPoint(x: xValue, y: yValue))
			}
			lines.append(DataLine(points: points, color: .green, name: "asd"))
		}

		self.init(lines: lines)
	}
}
