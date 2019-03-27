//
//  ChartDTO.swift
//  Copyright © 2019 Cleverpumpkin, Ltd. All rights reserved.
//

import Foundation

struct ChartDTO: Decodable {
//	let columns: [[Int]]
	let types: [String: String]
	let columns: [String: [Int]]
	let names: [String: String]
	let colors: [String: String]

	private enum CodingKeys: CodingKey {
		case columns
		case types
		case names
		case colors
	}

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)

		self.types = try container.decode([String: String].self, forKey: .types)

		var columns = [String: [Int]]()
		self.types.forEach { key, _ in columns[key] = [Int]() }

		var columnsContainer = try container.nestedUnkeyedContainer(forKey: .columns)
		while !columnsContainer.isAtEnd {
			var columnContainer = try columnsContainer.nestedUnkeyedContainer()
			var index = 0
			var columnType = ""
			while !columnContainer.isAtEnd {
				if index == 0 {
					columnType = try columnContainer.decode(String.self)
				} else {
					let rowValue = try columnContainer.decode(Int.self)
					columns[columnType]?.append(rowValue)
				}
				index += 1
			}
		}
		self.names = try container.decode([String: String].self, forKey: .names)
		self.colors = try container.decode([String: String].self, forKey: .colors)
		self.columns = columns
	}
}
