//
//  DataPoint.swift
//  Copyright © 2019 Cleverpumpkin, Ltd. All rights reserved.
//

import Foundation

struct DataPoint<XType, YType> {

}

extension DataPoint: Decodable where XType == Int, YType == Int {

}