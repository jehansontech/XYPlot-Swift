//
//  XYPlotModel.swift
//  XYPlotForSwift
//
//  Created by Jim Hanson on 3/26/22.
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

public class XYPlotModel: ObservableObject {

    public var hasTitle: Bool {
        return !title.isEmpty
    }

    public var title: String

    @Published public var layers = [XYLayer]()

    @Published public var selectedLayer: Int = 0

    @Published public var caption: String

    public init(title: String = "", caption: String = "") {
        self.title = title
        self.caption = caption
    }
}

public struct XYLayer {

    public var hasData: Bool {
        for dataSet in dataSets {
            if dataSet.points.count > 0 {
                return true
            }
        }
        return false
    }

    public var title: String

    public var xLabel: AxisLabel

    public var yLabel: AxisLabel

    public var bounds: XYRect? = nil

    public private(set) var dataSets = [XYDataSet]()

    public private(set) var dataBounds: XYRect? = nil

    public init(xLabel: AxisLabel, yLabel: AxisLabel) {
        self.xLabel = xLabel
        self.yLabel = yLabel
        self.title = "\(yLabel.name) vs. \(xLabel.name)"
    }

    /// returns new data set's index
    @discardableResult public mutating func addDataSet(_ label: String, _ color: Color = .black, _ stroke: Stroke = .solid) -> Int {
        let idx = dataSets.count
        dataSets.append(XYDataSet(label, color, stroke))
        return idx
    }

    public mutating func addPoint(_ dataSetIndex: Int, _ point: XYPoint) {
        dataSets[dataSetIndex].points.append(point)
        let newBounds = dataBounds?.cover(point) ?? XYRect(point)
        self.dataBounds = newBounds
        self.bounds = Self.fixBounds(newBounds)
    }

    public mutating func clearData() {
        for idx in dataSets.indices {
            dataSets[idx].points.removeAll()
        }
        bounds = nil
    }

    /// This expands the bounds so that axis numbers look good
    private static func fixBounds(_ trueBounds: XYRect) -> XYRect {

        let multiplierX = CGFloat(pow(10, Double(trueBounds.exponentX)))
        let minX2 = multiplierX * floor(trueBounds.minX / multiplierX)
        let maxX2 = multiplierX * ceil(trueBounds.maxX / multiplierX)

        let multiplierY = CGFloat(pow(10, Double(trueBounds.exponentY)))
        let minY2 = multiplierY * floor(trueBounds.minY / multiplierY)
        let maxY2 = multiplierY * ceil(trueBounds.maxY / multiplierY)

        // DEBUGGING
        //            if (minX2 != trueBounds.minX) {
        //                print("XYLayer3: adjusted minX: \(trueBounds.minX) -> \(minX2)")
        //            }
        //            if (maxX2 != trueBounds.maxX) {
        //                print("XYLayer3: adjusted maxX: \(trueBounds.maxX) -> \(maxX2)")
        //            }
        //            if minY2 != trueBounds.minY {
        //                print("XYLayer3: adjusted minY: \(trueBounds.minY) -> \(minY2)")
        //            }
        //            if (maxY2 != trueBounds.maxY) {
        //                print("XYLayer3: adjusted maxY: \(trueBounds.maxY) -> \(maxY2)")
        //            }

        return XYRect(x: minX2,
                      y: minY2,
                      width:  minX2 < maxX2 ? maxX2 - minX2 : 1,
                      height: minY2 < maxY2 ? maxY2 - minY2 : 1)
    }
}

public struct AxisLabel {

    public var name: String

    public var units: String?

    public init(_ name: String, _ units: String? = nil) {
        self.name = name
        self.units = units
    }

    func makeLabelText(_ exponent: Int) -> String {
        if let units = units {
            if exponent == 0 {
                return "\(name) (\(units))"
            }
            else if exponent == 1 {
                return "\(name) (\(units) x 10)"
            }
            else {
                return "\(name) (\(units) x 10^\(exponent))"
            }
        }
        else {
            if exponent == 0 {
                return name
            }
            else if exponent == 1 {
                return "\(name) (x 10)"
            }
            else {
                return "\(name) (x 10^\(exponent))"
            }
        }
    }
}

public struct XYDataSet {
    public var label: String
    public var color: Color
    public var stroke: Stroke
    public var points = [XYPoint]()

    public init(_ label: String, _ color: Color = .black, _ stroke: Stroke = .solid) {
        self.label = label
        self.color = color
        self.stroke = stroke
    }
}

public enum Stroke {
    case solid
}
