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
                        .fill()
                        .frame(width: 50, height: 2)
                    Text(lineName(idx))
                }
            }
        }
    }

    init(_ layer: Binding<XYLayer>, _ lineIndices: [Int]) {
        self._layer = layer
        self.lineIndices = lineIndices
    }

    func lineColor(_ idx: Int) -> Color {
        return layer.lines[idx].style.color
    }

    func lineName(_ idx: Int) -> String {
        return layer.lines[idx].dataSet.name ?? "(no label)"
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
        }
    }

    init(_ layer: Binding<XYLayer>) {
        self._layer = layer
        self.columns = Self.makeColumns(layer.wrappedValue.lines.count)
    }

    static func makeColumns(_ lineCount: Int) -> [[Int]] {
        var columns = [[Int]]()
        var nextIndex: Int = 0
        var remaining: Int = lineCount
        while remaining > XYPlotConstants.captionRows {
            let column = Array(nextIndex..<(nextIndex + XYPlotConstants.captionRows))
            columns.append(column)
            nextIndex += XYPlotConstants.captionRows
            remaining -= XYPlotConstants.captionRows
        }
        if (remaining > 0) {
            let column = Array(nextIndex..<lineCount)
            columns.append(column)

        }
        return columns
    }
}
