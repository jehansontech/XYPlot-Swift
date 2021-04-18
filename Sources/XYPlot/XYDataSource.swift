//
//  XYDataSource.swift
//  ArcWorld
//
//  Created by Jim Hanson on 3/28/21.
//

import SwiftUI

typealias XYPoint = CGPoint

typealias XYRect = CGRect

extension XYRect {

    init(_ p: XYPoint) {
        self.init(x: p.x, y: p.y, width: 0, height: 0)
    }

    func cover(_ point: XYPoint) -> XYRect {
        let minX = min(point.x, self.minX)
        let maxX = max(point.x, self.maxX)
        let minY = min(point.y, self.minY)
        let maxY = max(point.y, self.maxY)
        return XYRect(x: minX, y: minY, width: (maxX-minX), height: (maxY-minY))
    }
}

protocol XYDataSet {

    var color: Color? { get }

    var points: [XYPoint] { get }

    var bounds: XYRect? { get }
}

protocol XYDataSource {

    var xAxisName: String { get }

    var yAxisName: String { get }

    var dataSets: [XYDataSet] { get }
}

