//
//  XYLayerView.swift
//  ArcWorld
//
//  Created by Jim Hanson on 4/6/21.
//

import SwiftUI
import Taconic
import UIStuffForSwift

extension XYRect {

    var exponentX: Int {
        let m1 = orderOfMagnitude(Double(minX))
        let m2 = orderOfMagnitude(Double(maxX))
        let m3 = orderOfMagnitude(Double(width))
        let max = max(max(m1, m2), m3)
        return max - 1
    }

    var exponentY: Int {
        let m1 = orderOfMagnitude(Double(minY))
        let m2 = orderOfMagnitude(Double(maxY))
        let m3 = orderOfMagnitude(Double(height))
        let max = max(max(m1, m2), m3)
        return max - 1
    }
}


public struct XAxisLabelsView: View {

    @Binding var axisLabels: AxisLabels

    @Binding var dataBounds: XYRect

    public var body: some View {
        VStack(spacing: 0) {

            // TODO ticks and numbers
            
            HStack {
                Text(axisLabels.makeLabel(dataBounds.exponentX))
                    .lineLimit(1)
                    .font(Font.system(size: XYPlotConstants.axisLabelFontSize, design: .monospaced))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: XYPlotConstants.xAxisLabelsHeight)
    }

    public init(_ axisLabels: Binding<AxisLabels>, _ dataBounds: Binding<XYRect>) {
        self._axisLabels = axisLabels
        self._dataBounds = dataBounds
    }
}

public struct YAxisLabelsView: View {

    @Binding var axisLabels: AxisLabels

    @Binding var dataBounds: XYRect

    public var body: some View {
        HStack(spacing: 0) {

            VStack {
                Text(axisLabels.makeLabel(dataBounds.exponentY))
                    .lineLimit(1)
                    .rotated(by: .degrees(-90))
            }

            // TODO numbers and ticks

        }
        .frame(maxHeight: .infinity)
    }

    public init(_ axisLabels: Binding<AxisLabels>, _ dataBounds: Binding<XYRect>) {
        self._axisLabels = axisLabels
        self._dataBounds = dataBounds
    }
}


public struct XYLayerView: View {

    public var layerInsets = EdgeInsets(top: XYPlotConstants.layerTopInset, leading: 0, bottom: 0, trailing: XYPlotConstants.yAxisLabelsWidth)

    @Binding private var layer: XYLayer

    @State private var dataBounds = XYRect()

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

                Spacer()

                // y-axis names needs to be centered w/r/t GeometryReader
                YAxisLabelsView($layer.yAxisLabels, $dataBounds)

                // ==================================================================
                // Begin the plot

                GeometryReader { proxy in

                    let dataTransform = CGAffineTransform(scaleX: 1, y: -1)
                        .translatedBy(x: 0, y: -proxy.frame(in: .local).height)
                        .scaledBy(x: proxy.frame(in: .local).width / dataBounds.width,
                                  y: proxy.frame(in: .local).height / dataBounds.height)
                        .translatedBy(x: -dataBounds.minX, y: -dataBounds.minY)


                    ForEach(layer.lines.indices, id: \.self) { lineIdx in
                        let points = layer.lines[lineIdx].dataSet.points
                        if points.count > 0 {

                            Path { path in
                                path.move(to: points[0])
                                for j in 1..<points.count {
                                    path.addLine(to: points[j])
                                }
                            }
                            .applying(dataTransform)
                            .stroke(layer.lines[lineIdx].style.color)
                            .clipped()
                        }
                    }
                }
                .background(UIConstants.trueBlack)

                // End the plot
                // ==================================================================

            }
            // end HStack for y-axis labels and plot

            // begin HStack for x-axis labels
            HStack(spacing: 0) {

                // bottom left corner
                Spacer()
                    .frame(width: XYPlotConstants.yAxisLabelsWidth, height: XYPlotConstants.xAxisLabelsHeight)

                // x-axis label needs to be centered w.r.t GeometryReader
                XAxisLabelsView($layer.xAxisLabels, $dataBounds)
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

    public init(_ layer: Binding<XYLayer>) {
        self._layer = layer
        self._dataBounds = State(initialValue: Self.makeBounds(layer.wrappedValue))
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

    static func makeDefaultStyles(_ dataSource: XYDataSource) -> [XYLineStyle] {
        var styles = [XYLineStyle]()
        for _ in dataSource.dataSets {
            styles.append(XYLineStyle())
        }
        return styles
    }
}

