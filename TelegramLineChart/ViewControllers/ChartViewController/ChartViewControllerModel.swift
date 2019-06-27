//
//  ChartViewControllerDTO.swift
//  TelegramLineChart
//
//  Created by Valentin Vafiadi
//  Copyright © 2019 VFD. All rights reserved.
//

import Foundation

class ChartViewControllerModel {

    let lines: [DataLine]

    let totalXRange: ClosedRange<DataPoint.DataType>

    var lineHiddenFlags: [Bool]

    var selectedXRange: ClosedRange<DataPoint.DataType> = 0...0

    init(chart: Chart) {
        self.lines = chart.lines.sorted { $0.name < $1.name }
        lineHiddenFlags = [Bool](repeating: false, count: chart.lines.count)
        totalXRange = lines.xRange
    }
}


extension ChartViewControllerModel {
    static let mockModel: ChartViewControllerModel = {
        let data = ChartLoader.loadChartData()!
        let charts = try! ChartJSONParser.charts(from: data)
        return ChartViewControllerModel(chart: charts[0])
    }()
}