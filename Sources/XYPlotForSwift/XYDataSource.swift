//
//  XYDataSource.swift
//  ArcWorld
//
//  Created by Jim Hanson on 3/28/21.
//

import SwiftUI

public typealias XYPoint = CGPoint

public typealias XYRect = CGRect

public extension XYRect {

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

public protocol XYDataSet {

    var name: String? { get }
    
    var color: Color? { get }

    var points: [XYPoint] { get }

    var bounds: XYRect? { get }
}

public protocol XYDataSource {

    var xAxisName: String { get }

    var xAxisUnits: String? { get }

    var yAxisName: String { get }

    var yAxisUnits: String? { get }

    var dataSets: [XYDataSet] { get }
}

