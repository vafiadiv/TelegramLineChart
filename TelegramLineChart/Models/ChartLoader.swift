//
//  ChartLoader.swift
//  Copyright © 2019 Cleverpumpkin, Ltd. All rights reserved.
//

import Foundation


struct ChartLoader {

	//enum to avoid instantiation
	private enum Constants {
		static let fileName = "chart_data"
		static let fileExtension = "json"
	}

	static func loadChartData() -> Data? {
		guard let chartURL = Bundle.main.url(forResource: Constants.fileName, withExtension: Constants.fileExtension) else {
			return nil
		}
		let data = try? Data(contentsOf: chartURL)
		return data
	}
}
