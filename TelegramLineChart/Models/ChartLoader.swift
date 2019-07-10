//
//  ChartLoader.swift
//  TelegramLineChart
//
//  Created by Valentin Vafiadi
//  Copyright © 2019 VFD. All rights reserved.
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
