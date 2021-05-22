//
//  File.swift
//  
//
//  Created by Jim Hanson on 5/12/21.
//

import SwiftUI

struct CaptionColumn: View {

    @Binding var layer: XYLayer

    let lineIndices: [Int]

    var body: some View {
        VStack(alignment: .leading) {
            ForEach(lineIndices, id: \.self) { idx in
                HStack {
                    Rectangle()
                        .fill(layer.lines[idx].color)
                        .frame(width: 50, height: 2)
                    Text(lineLabel(idx))
                }
            }
        }
    }

    init(_ layer: Binding<XYLayer>, _ lineIndices: [Int]) {
        self._layer = layer
        self.lineIndices = lineIndices
    }

    func lineLabel(_ idx: Int) -> String {
        let label = layer.lines[idx].label
        return label.isEmpty ? "(no label)" : label
    }
}

struct CaptionView: View {

    @Binding var layer: XYLayer

    var columns: [[Int]]

    var body: some View {
        HStack(alignment: .top) {
            ForEach(columns, id: \.self) { column in
                CaptionColumn($layer, column)
            }
            Spacer()
        }
    }

    init(_ layer: Binding<XYLayer>) {
        self._layer = layer
        self.columns = Self.makeColumns(layer.wrappedValue.lines)
    }

    static func makeColumns(_ lines: [XYLine]) -> [[Int]] {
        var columns = [[Int]]()
        if lines.count > 1 || lines.count == 1 && !lines[0].label.isEmpty {
            var nextIndex: Int = 0
            var remaining: Int = lines.count
            while remaining > XYPlotConstants.captionRows {
                let column = Array(nextIndex..<(nextIndex + XYPlotConstants.captionRows))
                columns.append(column)
                nextIndex += XYPlotConstants.captionRows
                remaining -= XYPlotConstants.captionRows
            }
            if (remaining > 0) {
                let column = Array(nextIndex..<lines.count)
                columns.append(column)
            }
        }
        return columns
    }
}
