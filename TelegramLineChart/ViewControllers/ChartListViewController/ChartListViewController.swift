//
//  ChartListViewController.swift
//  TelegramLineChart
//
//  Created by Valentin Vafiadi
//  Copyright © 2019 VFD. All rights reserved.
//

import UIKit

class ChartListViewController: UITableViewController {

    private enum Constants {
        static let cellReuseIdentifier = "cellReuseIdentifier"
    }

    // MARK: - Private properties

    private var chartViewControllers = [ChartViewController]()

    // MARK: - Initialization

    init() {
        super.init(style: .grouped)
        title = "Statistics".localized
    }

    required init?(coder aDecoder: NSCoder) {
        notImplemented()
    }

    // MARK: - Overrides

    override func loadView() {
        super.loadView()
        setupData()
        setupTableView()
    }

    // MARK: - Private methods

    private func setupData() {
        guard let data = ChartLoader.loadChartData() else {
            return
        }

        guard let charts = try? ChartJSONParser.charts(from: data) else {
            let alert = UIAlertController(title: nil, message: "Error loading data".localized, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }

        chartViewControllers = charts.map {
            let model = ChartViewControllerModel(chart: $0)
            return ChartViewController(model: model)
        }
    }

    private func setupTableView() {
        tableView.register(ChartCell.self, forCellReuseIdentifier: Constants.cellReuseIdentifier)
    }

    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return String.localizedStringWithFormat("Chart #%d".localized, section)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return chartViewControllers.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellReuseIdentifier, for: indexPath) as? ChartCell else {
            fatalError("Cell not registered")
        }

        cell.hostedView = chartViewControllers[indexPath.section].view
        return cell
    }

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let numberOfLines = chartViewControllers[indexPath.section].model.lines.count
        return ChartView.height(for: tableView.frame.width, numberOfLines: numberOfLines)
    }
}
