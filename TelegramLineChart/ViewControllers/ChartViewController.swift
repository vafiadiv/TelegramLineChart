//
//  ViewController.swift
//  TelegramLineChart
//
//  Created by Valentin Vafiadi on 17/03/2019.
//  Copyright © 2019 VFD. All rights reserved.
//

import UIKit

class ChartViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupData()
    }

	private func setupData() {
		guard let data = ChartLoader.loadChartData() else {
			return
		}
		guard let charts = try? ChartJSONParser.charts(from: data) else {
			//TODO: error
			return
		}
		print(charts)
	}
}
