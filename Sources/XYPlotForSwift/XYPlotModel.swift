//
//  XYPlotConfig.swift
//  ArcWorld
//
//  Created by Jim Hanson on 4/9/21.
//

import SwiftUI
import Wacoma

public struct XYPlotModel {

    public var layers = [XYLayer]()

    public init(_ dataSource: XYDataSource) {
        layers.append(XYLayer(dataSource, true))
    }

    public init(_ dataSources: [XYDataSource]) {
        var showing = true
        for dataSource in dataSources {
            layers.append(XYLayer(dataSource, showing))
            showing = false
        }
    }
}

public struct XYLayer {

    public var title: String {
        return "\(yAxisLabels.name) vs. \(xAxisLabels.name)"
    }

    public var xAxisLabels: AxisLabels

    public var yAxisLabels: AxisLabels

    public var lines = [XYLine]()

    public var showing: Bool

    var colors: PresetColorIterator

    public init(_ dataSource: XYDataSource, _ showing: Bool) {
        self.xAxisLabels = XYLayer.makeXAxisLabels(dataSource)
        self.yAxisLabels = XYLayer.makeYAxisLabels(dataSource)
        self.showing = showing
        self.colors = PresetColorSequence().makeIterator()
        for dataSet in dataSource.dataSets {
            lines.append(XYLine(dataSet, makeStyle(dataSet)))
        }
    }

    private static func makeXAxisLabels(_ dataSource: XYDataSource) -> AxisLabels {
        return AxisLabels(name: dataSource.xAxisName, units: dataSource.xAxisUnits)
    }

    private static func makeYAxisLabels(_ dataSource: XYDataSource) -> AxisLabels {
        return AxisLabels(name: dataSource.yAxisName, units: dataSource.yAxisUnits)

    }

    private mutating func makeStyle(_ dataSet: XYDataSet) -> XYLineStyle {
        if let color = dataSet.color {
            return XYLineStyle(color: color)
        }
        else {
            return XYLineStyle(color: colors.next() ?? Color.black)
        }
    }
}

public struct XYLine {

    var label: String {
        return dataSet.name ?? ""
    }

    var color: Color {
        return style.color
    }
    
    public var dataSet: XYDataSet

    public var style: XYLineStyle

    public init(_ dataSet: XYDataSet, _ style: XYLineStyle) {
        self.dataSet = dataSet
        self.style = style
    }
}

public struct XYLineStyle {

    public var color = Color.white
}

public struct AxisLabels {

    public var name: String

    public var units: String?

    init(name: String, units: String? = nil) {
        self.name = name
        self.units = units
    }

    func makeLabel(_ exponent: Int) -> String {
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

