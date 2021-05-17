//
//  LayerView.swift
//  ArcWorld
//
//  Created by Jim Hanson on 4/6/21.
//

import SwiftUI
import Wacoma
import WacomaUI


public struct LayerView: View {

    @Binding private var layer: XYLayer

    @State private var dataBounds = XYRect()

    public var body: some View {

        VStack(spacing: 0) {

            Text(layer.title)
                .font(.headline)
                .frame(maxWidth: .infinity, minHeight: XYPlotConstants.titleHeight)

            HStack(spacing: 0) {
                YAxisView($layer.yAxisLabels, $dataBounds)
                    .frame(width: XYPlotConstants.yAxisLabelsWidth)
                LayerLinesView($layer, $dataBounds)
                Spacer()
                    .frame(width: XYPlotConstants.yAxisLabelsWidth)
            }

            HStack(spacing: 0) {
                Spacer()
                    .frame(width: XYPlotConstants.yAxisLabelsWidth, height: XYPlotConstants.xAxisLabelsHeight)
                XAxisView($layer.xAxisLabels, $dataBounds)
                    .frame(height: XYPlotConstants.xAxisLabelsHeight)
            }

            HStack(spacing: 0) {
                Spacer()
                    .frame(width: XYPlotConstants.yAxisLabelsWidth)
                CaptionView($layer)
                Spacer()
                    .frame(width: XYPlotConstants.yAxisLabelsWidth)
            }
            .frame(maxWidth: .infinity, minHeight: XYPlotConstants.captionHeight)
        }
        // .padding(layerInsets)
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

            if (minX2 != trueBounds.minX) {
                debug("LayerView: adjusted minX: \(trueBounds.minX) -> \(minX2)")
            }
            if (maxX2 != trueBounds.maxX) {
                debug("LayerView: adjusted maxX: \(trueBounds.maxX) -> \(maxX2)")
            }
            if minY2 != trueBounds.minY {
                debug("LayerView: adjusted minY: \(trueBounds.minY) -> \(minY2)")
            }
            if (maxY2 != trueBounds.maxY) {
                debug("LayerView: adjusted maxY: \(trueBounds.maxY) -> \(maxY2)")
            }

            return XYRect(x: minX2,
                          y: minY2,
                          width:  minX2 < maxX2 ? maxX2 - minX2 : 1,
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


struct LayerLinesView: View {

    @Binding var layer: XYLayer

    @Binding var dataBounds: XYRect

    var body: some View {
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
        // .clipped()
    }

    init(_ layer: Binding<XYLayer>, _ dataBounds: Binding<XYRect>) {
        self._layer = layer
        self._dataBounds = dataBounds
    }
}
