//
//  ChartJSONParser.swift
//  Copyright © 2019 Cleverpumpkin, Ltd. All rights reserved.
//

import Foundation
import UIKit.UIColor

struct ChartJSONParser {

	static func charts(from JSON: Data) throws -> [Chart] {

		let decoder = JSONDecoder()
		let chartDTOs = try decoder.decode([ChartJSONDTO].self, from: JSON)

		return try chartDTOs.map { try Chart(DTO: $0) }
	}
}

// MARK: -

private extension Chart {

	init(DTO: ChartJSONDTO) throws {
		guard let xColumnName = (DTO.types.first { _, value in value == "x" }?.key),
			  let xColumn = DTO.columns[xColumnName] else {
			throw DecodingError.general("Error finding \"x\" column")
		}

		var lines = [DataLine]()
		//one column is "x"
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
			var color: UIColor? = nil
			if let colorHexString = DTO.colors[key] {
				color = UIColor(hex: colorHexString)
			}
			lines.append(DataLine(points: points, color: color ?? .red, name: DTO.names[key] ?? ""))
		}

		self.init(lines: lines)
	}
}
