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

    let formatter: NumberFormatter

    @Binding var axisLabels: AxisLabels

    @Binding var dataBounds: XYRect

    var multiplier: CGFloat {
        return CGFloat(pow(10,Double(dataBounds.exponentX)))
    }

    public var body: some View {
        VStack(spacing: 0) {

            GeometryReader { proxy in

                let dataTransform = CGAffineTransform(scaleX: proxy.frame(in: .local).width / dataBounds.width, y: 1)
                    .translatedBy(x: -dataBounds.minX, y: -dataBounds.minY)

                ForEach(makeNumbers(), id: \.self) { n in

                    Path { path in
                        path.move(to:    CGPoint(x: multiplier * CGFloat(n), y: proxy.frame(in: .local).minY))
                        path.addLine(to: CGPoint(x: multiplier * CGFloat(n), y: proxy.frame(in: .local).minY + XYPlotConstants.tickLength))
                    }
                    .applying(dataTransform)
                    .stroke()

                    Text(formatter.string(for: n)!)
                        .font(Font.system(size: XYPlotConstants.axisLabelFontSize, design: .monospaced))
                        .fixedSize()
                        .position(CGPoint(x: multiplier * CGFloat(n), y: (proxy.frame(in: .local).minY  + XYPlotConstants.axisLabelCharHeight/2)).applying(dataTransform))
                }
            }

            HStack {
                Text(axisLabels.makeLabel(dataBounds.exponentX))
                    .font(Font.system(size: XYPlotConstants.axisLabelFontSize, design: .monospaced))
                    .fixedSize()
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: XYPlotConstants.xAxisLabelsHeight)
    }

    public init(_ axisLabels: Binding<AxisLabels>, _ dataBounds: Binding<XYRect>) {
        self.formatter = NumberFormatter()
        self.formatter.numberStyle = .none
        self._axisLabels = axisLabels
        self._dataBounds = dataBounds
    }

    func makeNumbers() -> [Int] {
        var numbers = [Int]()
        let min: Int = Int(floor(dataBounds.minX / multiplier))
        let max: Int = Int(ceil(dataBounds.maxX / multiplier))
        for n in stride(from: min, through: max, by: getStride(max - min)) {
            numbers.append(n)
        }
        return numbers
    }
}

public struct YAxisLabelsView: View {

    let formatter: NumberFormatter

    @Binding var axisLabels: AxisLabels

    @Binding var dataBounds: XYRect

    var multiplier: CGFloat {
        return CGFloat(pow(10,Double(dataBounds.exponentY)))
    }

    public var body: some View {

        HStack(spacing: 0) {

            Text(axisLabels.makeLabel(dataBounds.exponentY))
                .font(Font.system(size: XYPlotConstants.axisLabelFontSize, design: .monospaced))
                .fixedSize()
                .lineLimit(1)
                .rotated(by: .degrees(-90))

            GeometryReader { proxy in

                let dataTransform = CGAffineTransform(scaleX: 1, y: -1)
                    .translatedBy(x: 0, y: -proxy.frame(in: .local).height)
                    .scaledBy(x: 1, y: proxy.frame(in: .local).height / dataBounds.height)
                    .translatedBy(x: 0, y: -dataBounds.minY)

                ForEach(makeNumbers(), id: \.self) { n in

                    Text(formatter.string(for: n)!)
                        .font(Font.system(size: XYPlotConstants.axisLabelFontSize, design: .monospaced))
                        .fixedSize()
                        .position(CGPoint(x: proxy.frame(in: .local).maxX - numberOffset(n), y: multiplier * CGFloat(n)).applying(dataTransform))

                    Path { path in
                        path.move(to: CGPoint(x: proxy.frame(in: .local).maxX, y: multiplier * CGFloat(n)))
                        path.addLine(to: CGPoint(x: proxy.frame(in: .local).maxX - XYPlotConstants.tickLength, y: multiplier * CGFloat(n)))
                    }
                    .applying(dataTransform)
                    .stroke()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    public init(_ axisLabels: Binding<AxisLabels>, _ dataBounds: Binding<XYRect>) {
        self.formatter = NumberFormatter()
        self.formatter.numberStyle = .none
        self._axisLabels = axisLabels
        self._dataBounds = dataBounds
    }

    func makeNumbers() -> [Int] {
        var numbers = [Int]()
        let min: Int = Int(floor(dataBounds.minY / multiplier))
        let max: Int = Int(ceil(dataBounds.maxY / multiplier))
        for n in stride(from: min, through: max, by: getStride(max - min)) {
            numbers.append(n)
        }
        return numbers
    }

    func numberOffset(_ n: Int) -> CGFloat {
        // TODO
        return XYPlotConstants.axisLabelCharWidth / 2
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

                YAxisLabelsView($layer.yAxisLabels, $dataBounds) // centered w/r/t plot
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

                XAxisLabelsView($layer.xAxisLabels, $dataBounds) // centered w/r/t the plot
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

fileprivate func digitCount(_ n: Int) -> Int {
    var count = (n < 0) ? 1 : 0

    let n2 = abs(n)
    if (n2 < 10) {
        count += 1
    }
    else if (n2 < 100) {
        count += 2
    }
    else {
        count += 3
    }
    return count
}

fileprivate func getStride(_ delta: Int) -> Int{
    if delta > 50 {
        return 10
    }
    else if delta > 20 {
        return 5
    }
    else if delta > 10 {
        return 2
    }
    else {
        return 1
    }
}

