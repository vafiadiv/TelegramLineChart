//
//  LineTypeDTO.swift
//  Copyright © 2019 Cleverpumpkin, Ltd. All rights reserved.
//

import Foundation

enum LineTypeDTO: String, Decodable {
	case line
	case x

	init(from decoder: Decoder) throws {
		let rawValue = try decoder.singleValueContainer().decode(String.self)
		guard let lineTypeDTO = LineTypeDTO(rawValue: rawValue) else {
			throw DecodingError.general("asd")
		}
		self = lineTypeDTO
	}
}
