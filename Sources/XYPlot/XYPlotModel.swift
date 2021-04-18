//
//  XYPlotConfig.swift
//  ArcWorld
//
//  Created by Jim Hanson on 4/9/21.
//

import SwiftUI


struct XYLineStyle {

    var color = Color.white
}

struct AxisLabels {
    var name: String
}

struct XYLine {

    var dataSet: XYDataSet

    var style: XYLineStyle

    init(_ dataSet: XYDataSet, _ style: XYLineStyle) {
        self.dataSet = dataSet
        self.style = style
    }
}

struct XYLayer {

    var title: String {
        return "\(yAxisLabels.name) vs. \(xAxisLabels.name)"
    }

    var xAxisLabels: AxisLabels

    var yAxisLabels: AxisLabels

    var lines = [XYLine]()

    var showing: Bool

    init(_ dataSource: XYDataSource, _ showing: Bool) {
        self.xAxisLabels = XYLayer.makeXAxisLabels(dataSource)
        self.yAxisLabels = XYLayer.makeYAxisLabels(dataSource)
        self.showing = showing

        for dataSet in dataSource.dataSets {
            lines.append(XYLine(dataSet, makeStyle(dataSet)))
        }
    }

    private static func makeXAxisLabels(_ dataSource: XYDataSource) -> AxisLabels {
        return AxisLabels(name: dataSource.xAxisName)
    }

    private static func makeYAxisLabels(_ dataSource: XYDataSource) -> AxisLabels {
        return AxisLabels(name: dataSource.yAxisName)

    }

    private func makeStyle(_ dataSet: XYDataSet) -> XYLineStyle {
        if let color = dataSet.color {
            return XYLineStyle(color: color)
        }
        else {
            return XYLineStyle()
        }
    }
}

struct XYPlotModel {

    var layers = [XYLayer]()

    init(_ dataSource: XYDataSource) {
        layers.append(XYLayer(dataSource, true))
    }

    init(_ dataSources: [XYDataSource]) {
        var showing = true
        for dataSource in dataSources {
            layers.append(XYLayer(dataSource, showing))
            showing = false
        }
    }
 }
