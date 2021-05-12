//
//  File.swift
//  
//
//  Created by Jim Hanson on 5/10/21.
//

import SwiftUI
import Wacoma
import WacomaUI

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


public struct XAxisView: View {

    let formatter: NumberFormatter

    @Binding var axisLabels: AxisLabels

    @Binding var dataBounds: XYRect

    var multiplier: CGFloat {
        return CGFloat(pow(10,Double(dataBounds.exponentX)))
    }

    public var body: some View {
        VStack(spacing: 0) {

            GeometryReader { proxy in

                // XYLayer:
                //                let dataTransform = CGAffineTransform(scaleX: 1, y: -1)
                //                    .translatedBy(x: 0, y: -proxy.frame(in: .local).height)
                //                    .scaledBy(x: proxy.frame(in: .local).width / dataBounds.width,
                //                              y: proxy.frame(in: .local).height / dataBounds.height)
                //                    .translatedBy(x: -dataBounds.minX, y: -dataBounds.minY)

                let dataTransform = CGAffineTransform(scaleX: proxy.frame(in: .local).width / dataBounds.width, y: 1)
                    .translatedBy(x: -dataBounds.minX, y: 0)

                ForEach(makeNumbers(), id: \.self) { n in

                    Path { path in
                        path.move(to:    CGPoint(x: multiplier * CGFloat(n), y: proxy.frame(in: .local).minY))
                        path.addLine(to: CGPoint(x: multiplier * CGFloat(n), y: proxy.frame(in: .local).minY + XYPlotConstants.axisTickLength))
                    }
                    .applying(dataTransform)
                    .stroke()

                    Text(formatter.string(for: n)!)
                        .font(Font.system(size: XYPlotConstants.axisLabelFontSize, design: .monospaced))
                        .fixedSize()
                        .position(CGPoint(x: multiplier * CGFloat(n), y: (proxy.frame(in: .local).minY + XYPlotConstants.axisTickLength + numberOffset(n))).applying(dataTransform))
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
        if numbers[numbers.count-1] < max {
            numbers.append(max)
        }
        return numbers
    }

    func numberOffset(_ n: Int) -> CGFloat {
        return XYPlotConstants.axisLabelCharHeight / 2
    }
}

public struct YAxisView: View {

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
                        .position(CGPoint(x: proxy.frame(in: .local).maxX - XYPlotConstants.axisTickLength - numberOffset(n), y: multiplier * CGFloat(n)).applying(dataTransform))

                    Path { path in
                        path.move(to: CGPoint(x: proxy.frame(in: .local).maxX, y: multiplier * CGFloat(n)))
                        path.addLine(to: CGPoint(x: proxy.frame(in: .local).maxX - XYPlotConstants.axisTickLength, y: multiplier * CGFloat(n)))
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
        if numbers[numbers.count-1] < max {
            numbers.append(max)
        }
        return numbers
    }

    func numberOffset(_ n: Int) -> CGFloat {
        return CGFloat(digitCount(n)) * XYPlotConstants.axisLabelCharWidth / 2
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

