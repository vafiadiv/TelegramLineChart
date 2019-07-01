//
//  DataLineSelectViewController.swift
//  TelegramLineChart
//
//  Created by Valentin Vafiadi
//  Copyright © 2019 VFD. All rights reserved.
//

import UIKit

class DataLineSelectViewController: UITableViewController {

    private enum Constants {
        static let cellReuseIdentifier = "cellReuseIdentifier"
    }

    // MARK: - Private properties

    private var dataLines: [DataLine] = []

/*
    // MARK: - Initialization

    init(dataLines: [DataLine]) {
        self.dataLines = dataLines
        super.init(style: .plain)
    }

    required init?(coder aDecoder: NSCoder) {
        notImplemented()
    }

*/
    private func setupTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.cellReuseIdentifier)
    }

    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataLines.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellReuseIdentifier) else {
            fatalError("Cell not registered")
        }

        cell.textLabel?.text = dataLines[indexPath.row].name
        return cell
    }
}
