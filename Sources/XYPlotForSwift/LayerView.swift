//
//  LayerView.swift
//  ArcWorld
//
//  Created by Jim Hanson on 4/6/21.
//

import SwiftUI
import Taconic
import UIStuffForSwift

public struct LayerView: View {

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

                YAxisView($layer.yAxisLabels, $dataBounds) // centered w/r/t plot
                    .frame(width: XYPlotConstants.yAxisLabelsWidth)
                    //.clipped()

                // Begin plot
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
                        }
                    }
                }
                .background(UIConstants.trueBlack)
                .clipped()
                // End plot

            }
            // end HStack for y-axis labels and plot

            // begin HStack for x-axis labels
            HStack(spacing: 0) {

                // bottom left corner
                Spacer()
                    .frame(width: XYPlotConstants.yAxisLabelsWidth, height: XYPlotConstants.xAxisLabelsHeight)

                XAxisView($layer.xAxisLabels, $dataBounds) // centered w/r/t the plot
                    .frame(height: XYPlotConstants.xAxisLabelsHeight)
                    //.clipped()
            }
            // end HStack for x-axis labels

            // begin HStack for caption
            HStack(spacing: 0) {

                // TODO legend: name and color for each line

                Spacer()
                    .frame(width: XYPlotConstants.yAxisLabelsWidth, height: XYPlotConstants.xAxisLabelsHeight)

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
        var trueBounds: XYRect? = nil
        for line in layer.lines {
            if let b2 = line.dataSet.bounds {
                if let oldBounds = trueBounds {
                    trueBounds = oldBounds.union(b2)
                }
                else {
                    trueBounds = b2
                }
            }
        }

        if let trueBounds = trueBounds {

            // Expand them so that axis numbers look good

            let multiplierX = CGFloat(pow(10, Double(trueBounds.exponentX)))
            let minX2 = multiplierX * floor(trueBounds.minX / multiplierX)
            let maxX2 = multiplierX * ceil(trueBounds.maxX / multiplierX)

            let multiplierY = CGFloat(pow(10, Double(trueBounds.exponentY)))
            let minY2 = multiplierY * floor(trueBounds.minY / multiplierY)
            let maxY2 = multiplierY * ceil(trueBounds.maxY / multiplierY)

            return XYRect(x: minX2,
                          y: minY2,
                          width: minX2 < maxX2 ? maxX2 - minX2: 1,
                          height: minY2 < maxY2 ? maxY2 - minY2 : 1)
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

