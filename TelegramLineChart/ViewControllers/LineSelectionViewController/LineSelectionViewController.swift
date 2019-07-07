//
//  DataLineSelectViewController.swift
//  TelegramLineChart
//
//  Created by Valentin Vafiadi
//  Copyright © 2019 VFD. All rights reserved.
//

import UIKit

class LineSelectionViewController: UIViewController, RootViewProtocol {

    typealias RootViewType = LineSelectionView

    private enum Constants {
        static let cellReuseIdentifier = "cellReuseIdentifier"
    }

    // MARK: - Public properties

    var dataLines = [DataLine]()

    var dataLineHiddenFlags = [Bool]()

    weak var delegate: LineSelectionViewControllerDelegate?

    // MARK: - Overrides

    override func loadView() {
        view = LineSelectionView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }

    // MARK: - Private methods

    private func setupTableView() {
        rootView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.cellReuseIdentifier)
        rootView.delegate = self
        rootView.dataSource = self
        rootView.bounces = false
    }
}

// MARK: - UITableViewDataSource

extension LineSelectionViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataLines.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellReuseIdentifier) else {
            fatalError("Cell not registered")
        }

        cell.textLabel?.text = dataLines[indexPath.row].name
        cell.accessoryType = dataLineHiddenFlags[indexPath.row] ? .none : .checkmark

        return cell
    }
}

extension LineSelectionViewController: UITableViewDelegate {
/*
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 54.0
    }
*/

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.didSelectLine(at: indexPath.row)
    }
}