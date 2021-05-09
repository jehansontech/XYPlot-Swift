//
//  XYLayerView.swift
//  ArcWorld
//
//  Created by Jim Hanson on 4/6/21.
//

import SwiftUI
import UIStuffForSwift

//extension XYRect {
//
//    func mapToFrame(_ gp: GeometryProxy,  _ pt: CGPoint) -> CGPoint {
//        let frame = gp.frame(in: .local)
//        return CGPoint(x: frame.width  * (pt.x - self.minX)     / self.width   + frame.minX,
//                       y: frame.height * (1 - pt.y + self.minY) / self.height  + frame.minY)
//    }
//
//}

public struct XAxisLabelsView: View {

    public var axisLabels: AxisLabels

    public var bounds: XYRect

    public var orderOfMagnitude: Int

    public var body: some View {
        VStack(spacing: 0) {
            HStack {
                // TODO axis numbers
                Text("L")
                Spacer()
                Text("R")
            }
            GeometryReader { geometry in
                // TODO axis ticks
                Path {
                    path in
                    path.move(to: CGPoint(x: 0, y: 0))
                    path.addLine(to: CGPoint(x: 0, y: -10))
                }
                .stroke(Color.blue)

                Path {
                    path in
                    path.move(to: CGPoint(x: 1, y: 0))
                    path.addLine(to: CGPoint(x: 1, y: -10))
                }
                .stroke(Color.blue)
            }.border(Color.red)
            HStack {
                Text(axisLabels.makeLabel(orderOfMagnitude))
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: XYPlotConstants.xAxisLabelsHeight)
    }

    public init(_ axisLabels: AxisLabels, _ bounds: XYRect, _ orderOfMagnitude: Int) {
        self.axisLabels = axisLabels
        self.bounds = bounds
        self.orderOfMagnitude = orderOfMagnitude
    }
}

public struct YAxisLabelsView: View {

    public var axisLabels: AxisLabels

    public var bounds: XYRect

    public var orderOfMagnitude: Int

    public var body: some View {
        HStack(spacing: 0) {
            VStack {
                Text(axisLabels.makeLabel(orderOfMagnitude))
                    .lineLimit(1)
                    .rotated(by: .degrees(-90))
            }
            VStack {
                // TODO axis numbers
                Text("T")
                Spacer()
                Text("B")
            }
            GeometryReader { geometry in
                // TODO axis ticks
                Path {
                    path in
                    path.move(to: CGPoint(x: 0, y: 0))
                    path.addLine(to: CGPoint(x: -10, y: 0))
                }
                .stroke(Color.blue)

                Path {
                    path in
                    path.move(to: CGPoint(x: 0, y: 1))
                    path.addLine(to: CGPoint(x: -10, y: 1))
                }
                .stroke(Color.blue)

            }.border(Color.red)
        }
        .frame(maxWidth: XYPlotConstants.yAxisLabelsWidth, maxHeight: .infinity)
    }

    public init(_ axisLabels: AxisLabels, _ bounds: XYRect, _ orderOfMagnitude: Int) {
        self.axisLabels = axisLabels
        self.bounds = bounds
        self.orderOfMagnitude = orderOfMagnitude
    }
}

public struct XYLayerView: View {

    public var layerInsets = EdgeInsets(top: XYPlotConstants.layerTopInset, leading: 0, bottom: 0, trailing: XYPlotConstants.yAxisLabelsWidth)

    public let layer: XYLayer

    public let bounds: XYRect

    var xAxisOrderOfMagnitude: Int = 0

    var yAxisOrderOfMagnitude: Int = 0


    public var body: some View {

        VStack(spacing: 0) {

            // begin HStack for title
            HStack(spacing: 0) {

                // top right corner
                Spacer()
                    .frame(width: XYPlotConstants.yAxisLabelsWidth, height: XYPlotConstants.xAxisLabelsHeight)

                // title needs to be centered over GeometryReader
                Text(layer.title)
                    .font(.headline)
            }
            .frame(maxWidth: .infinity, minHeight: XYPlotConstants.titleHeight)
            // end HStack for title

            // begin HStack for y-axis labels and plot
            HStack(spacing: 0) {

                // y-axis names needs to be centered w/r/t GeometryReader
                YAxisLabelsView(layer.yAxisLabels, bounds, yAxisOrderOfMagnitude)

                GeometryReader { geometry in

                    ForEach(layer.lines.indices, id: \.self) { lineIdx in
                        let points = layer.lines[lineIdx].dataSet.points
                        if points.count > 0 {

                            Path { path in
                                path.move(to: mapToFrame(geometry, points[0], bounds))
                                for j in 1..<points.count {
                                    path.addLine(to: mapToFrame(geometry, points[j], bounds))
                                }
                            }
                            .stroke(layer.lines[lineIdx].style.color)
                            .clipped()
                        }
                    }
                }
                .background(UIConstants.trueBlack)
                // (No border b/c it might hide data line)
                // .border(UIConstants.darkGray)
                // end GeometryReader

            }
            // end HStack for y-axis labels and plot

            // begin HStack for x-axis labels
            HStack(spacing: 0) {

                // bottom left corner
                Spacer()
                    .frame(width: XYPlotConstants.yAxisLabelsWidth, height: XYPlotConstants.xAxisLabelsHeight)

                // x-axis label needs to be centered w.r.t GeometryReader
                XAxisLabelsView(layer.xAxisLabels, bounds, xAxisOrderOfMagnitude)
            }
            // end HStack for x-axis labels

            // begin HStack for caption
            HStack(spacing: 0) {

                Spacer()
                    .frame(width: XYPlotConstants.yAxisLabelsWidth, height: XYPlotConstants.xAxisLabelsHeight)

                // Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus in malesuada augue. Maecenas sed ante lorem. Vivamus in quam in lacus tincidunt volutpat ac ac justo. Nullam ornare vehicula quam, ac molestie velit fringilla sit amet. Donec quis dignissim risus, vel hendrerit magna. Vivamus vitae ornare justo, sit amet auctor diam. Quisque at tellus risus. Mauris nisi leo, ornare at sapien ac, mollis sodales lectus. Aliquam efficitur nec dolor laoreet imperdiet. In vehicula odio velit. Donec rutrum aliquam enim ac iaculis. Nullam vel nibh purus.")
            }
            .frame(maxWidth: .infinity, minHeight: XYPlotConstants.captionHeight)
            // end HStack for caption
        }
        .padding(layerInsets)
    }

    public init(_ layer: XYLayer) {
        self.layer = layer
        self.bounds = Self.makeBounds(layer)
    }

    static func makeBounds(_ layer: XYLayer) -> XYRect {
        var bounds: XYRect? = nil
        for line in layer.lines {
            if let b2 = line.dataSet.bounds {
                if let oldBounds = bounds {
                    bounds = oldBounds.union(b2)
                }
                else {
                    bounds = b2
                }
            }
        }

        if let bounds = bounds {
            return XYRect(x: bounds.minX,
                          y: bounds.minY,
                          width: bounds.width > 0 ? bounds.width : 1,
                          height: bounds.height > 0 ? bounds.height : 1)
        }
        else {
            return XYRect(x: 0, y: 0, width: 1, height: 1)
        }
    }

    func mapToFrame(_ gp: GeometryProxy,  _ pt: CGPoint, _ bounds: XYRect) -> CGPoint {

        let frame = gp.frame(in: .local)
        return CGPoint(x: frame.width  * (pt.x - bounds.minX)     / bounds.width   + frame.minX,
                       y: frame.height * (1 - pt.y + bounds.minY) / bounds.height  + frame.minY)
    }

    static func makeDefaultStyles(_ dataSource: XYDataSource) -> [XYLineStyle] {
        var styles = [XYLineStyle]()
        for _ in dataSource.dataSets {
            styles.append(XYLineStyle())
        }
        return styles
    }
}
