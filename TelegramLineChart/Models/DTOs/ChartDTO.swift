//
//  ChartDTO.swift
//  Copyright © 2019 Cleverpumpkin, Ltd. All rights reserved.
//

import Foundation

struct ChartDTO: Decodable {
//	let columns: [[Int]]
	let types: [String: String]

	private enum CodingKeys: CodingKey {
		case columns
		case types
		case names
		case colors
	}

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)

		let dict = try container.decode([String: String].self, forKey: .types)
		self.types = dict
	}
}
