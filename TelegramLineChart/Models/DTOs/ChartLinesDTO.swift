//
//  ChartLinesDTO.swift
//  Copyright © 2019 Cleverpumpkin, Ltd. All rights reserved.
//

import Foundation

struct ChartLinesDTO: Decodable {
	let y0: LineTypeDTO
	let y1: LineTypeDTO
	let x: LineTypeDTO

/*
	private enum CodingKeys: String, CodingKey {
		case y0
		case y1
		case x
	}
*/
}
