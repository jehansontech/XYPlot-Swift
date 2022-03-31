//
//  AxisViews.swift
//  XYPlotForSwift
//
//  Created by Jim Hanson on 5/10/21.
//

import SwiftUI
import Wacoma

extension XYRect {

    var exponentX: Int {

        let m1 = Double.orderOfMagnitude(Double(minX))
        let m2 = Double.orderOfMagnitude(Double(maxX))
        let m3 = Double.orderOfMagnitude(Double(width))
        let max = max(max(m1, m2), m3)
        var exponent = max - 1


        // FIXME EVIL HACKERY
        let multiplier = CGFloat(pow(10,Double(exponent)))
        let min2: Int = Int(floor(self.minX / multiplier))
        let max2: Int = Int(ceil(self.maxX / multiplier))
        let delta = max2 - min2
        if (delta > 50) {
            exponent += 1
        }

        return exponent
    }

    var exponentY: Int {
        let m1 = Double.orderOfMagnitude(Double(minY))
        let m2 = Double.orderOfMagnitude(Double(maxY))
        let m3 = Double.orderOfMagnitude(Double(height))
        let max = max(max(m1, m2), m3)
        var exponent = max - 1


        // FIXME EVIL HACKERY
        let multiplier = CGFloat(pow(10,Double(exponent)))
        let min2: Int = Int(floor(self.minY / multiplier))
        let max2: Int = Int(ceil(self.maxY / multiplier))
        let delta = max2 - min2
        if (delta > 50) {
            exponent += 1
        }

        return exponent
    }
}

struct XAxisView: View {

    var layer: XYLayer

    let formatter: NumberFormatter

    var minX: CGFloat {
        if let bounds = layer.bounds {
            return bounds.minX
        }
        else {
            return 0
        }
    }

    var maxX: CGFloat {
        if let bounds = layer.bounds {
            return bounds.maxX
        }
        else {
            return 1
        }
    }

    var width: CGFloat {
        if let bounds = layer.bounds {
            return bounds.width > 0 ? bounds.width : 1
        }
        else {
            return 1
        }
    }

    var exponent: Int {
        if let bounds = layer.bounds {
            return bounds.exponentX
        }
        else {
            return 0
        }
    }

    var multiplier: CGFloat {
        return CGFloat(pow(10,Double(exponent)))
    }

    var body: some View {
        VStack(spacing: 0) {

            if layer.hasData {
                GeometryReader { proxy in

                    // XYLayer:
                    //                let dataTransform = CGAffineTransform(scaleX: 1, y: -1)
                    //                    .translatedBy(x: 0, y: -proxy.frame(in: .local).height)
                    //                    .scaledBy(x: proxy.frame(in: .local).width / dataBounds.width,
                    //                              y: proxy.frame(in: .local).height / dataBounds.height)
                    //                    .translatedBy(x: -dataBounds.minX, y: -dataBounds.minY)

                    let dataTransform = CGAffineTransform(scaleX: proxy.frame(in: .local).width / width, y: 1)
                        .translatedBy(x: -minX, y: 0)

                    ForEach(numbers, id: \.self) { n in

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
            }

            HStack {
                Text(layer.xLabel.makeLabelText(exponent))
                    .font(Font.system(size: XYPlotConstants.axisLabelFontSize, design: .monospaced))
                    .fixedSize()
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: XYPlotConstants.xAxisLabelsHeight)
    }

    init(_ layer: XYLayer) {
        self.layer = layer
        self.formatter = NumberFormatter()
        self.formatter.numberStyle = .none
    }

    var numbers: [Int] {
        var numbers = [Int]()
        let min: Int = Int(floor(minX / multiplier))
        let max: Int = Int(ceil(maxX / multiplier))
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

struct YAxisView: View {

    var layer: XYLayer

    let formatter: NumberFormatter

    var minY: CGFloat {
        if let bounds = layer.bounds {
            return bounds.minY
        }
        else {
            return 0
        }
    }

    var maxY: CGFloat {
        if let bounds = layer.bounds {
            return bounds.maxY
        }
        else {
            return 1
        }
    }

    var height: CGFloat {
        if let bounds = layer.bounds {
            return bounds.height > 0 ?  bounds.height : 1
        }
        else {
            return 1
        }
    }

    var exponent: Int {
        if let bounds = layer.bounds {
            return bounds.exponentY
        }
        else {
            return 0
        }
    }

    var multiplier: CGFloat {
        return CGFloat(pow(10,Double(exponent)))
    }

    var numbers: [Int] {
        var numbers = [Int]()
        let min: Int = Int(floor(minY / multiplier))
        let max: Int = Int(ceil(maxY / multiplier))
        for n in stride(from: min, through: max, by: getStride(max - min)) {
            numbers.append(n)
        }
        if numbers[numbers.count-1] < max {
            numbers.append(max)
        }
        return numbers
    }

    var body: some View {
        HStack(spacing: 0) {

            Text(layer.yLabel.makeLabelText(exponent))
                .font(Font.system(size: XYPlotConstants.axisLabelFontSize, design: .monospaced))
                .fixedSize()
                .lineLimit(1)
                .rotated(by: .degrees(-90))

            if layer.hasData {
                GeometryReader { proxy in

                    let dataTransform = CGAffineTransform(scaleX: 1, y: -1)
                        .translatedBy(x: 0, y: -proxy.frame(in: .local).height)
                        .scaledBy(x: 1, y: proxy.frame(in: .local).height / height)
                        .translatedBy(x: 0, y: -minY)

                    ForEach(numbers, id: \.self) { n in

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
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    init(_ layer: XYLayer) {
        self.layer = layer
        self.formatter = NumberFormatter()
        self.formatter.numberStyle = .none
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
