//
//  LegendView.swift
//  XYPlotForSwift
//
//  Created by Jim Hanson on 3/31/22.
//

import SwiftUI

struct LegendColumn: View {

    var layer: XYLayer

    let lineIndices: [Int]

    var colors: XYPlotColors

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(lineIndices, id: \.self) { idx in
                HStack {
                    // TODO use the stroke
                    Rectangle()
                        .fill(colors.color(forNumber: layer.dataSets[idx].colorNumber))
                        .frame(width: 50, height: 2)

                    Text(lineLabel(idx))
                }
            }
        }
    }

    init(_ layer: XYLayer, _ lineIndices: [Int], _ colors: XYPlotColors) {
        self.layer = layer
        self.lineIndices = lineIndices
        self.colors = colors
    }

    func lineLabel(_ idx: Int) -> String {
        let label = layer.dataSets[idx].label
        return label.isEmpty ? "(no label)" : label
    }
}

struct LegendView: View {

    var layer: XYLayer

    var columns: [[Int]]

    var colors: XYPlotColors

    var body: some View {
        HStack(alignment: .top) {
            ForEach(columns, id: \.self) { column in
                LegendColumn(layer, column, colors)
            }
        }
    }

    init(_ layer: XYLayer, _ colors: XYPlotColors) {
        self.layer = layer
        self.columns = Self.makeColumns(layer.dataSets)
        self.colors = colors
    }

    static func makeColumns(_ lines: [XYDataSet]) -> [[Int]] {
        var columns = [[Int]]()
        if lines.count > 1 || lines.count == 1 && !lines[0].label.isEmpty {
            var nextIndex: Int = 0
            var remaining: Int = lines.count
            while remaining > XYPlotConstants.legendRows {
                let column = Array(nextIndex..<(nextIndex + XYPlotConstants.legendRows))
                columns.append(column)
                nextIndex += XYPlotConstants.legendRows
                remaining -= XYPlotConstants.legendRows
            }
            if (remaining > 0) {
                let column = Array(nextIndex..<lines.count)
                columns.append(column)
            }
        }
        return columns
    }
}

