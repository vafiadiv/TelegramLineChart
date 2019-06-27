//
//  ChartListViewController.swift
//  TelegramLineChart
//
//  Created by Valentin Vafiadi
//  Copyright © 2019 VFD. All rights reserved.
//

import UIKit

class ChartListViewController: UITableViewController {

    // MARK: - Private properties

    private var chartViewControllers = [ChartViewController]()

    // MARK: - Overrides

    override func loadView() {
        super.loadView()

    }

    // MARK: - Private methods

    private func setupData() {
        guard let data = ChartLoader.loadChartData() else {
            return
        }

        guard let charts = try? ChartJSONParser.charts(from: data) else {
            //TODO: error
            return
        }
    }

    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return super.tableView(tableView, cellForRowAt: indexPath)
    }

}
