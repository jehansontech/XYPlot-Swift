//
//  LayerView.swift
//  XYPlotForSwift
//
//  Created by Jim Hanson on 3/31/22.
//

import SwiftUI

struct LayerView: View {

    var layer: XYLayer

    var minX: CGFloat {
        if let bounds = layer.bounds {
            return bounds.minX
        }
        else {
            return 0
        }
    }

    var minY: CGFloat {
        if let bounds = layer.bounds {
            return bounds.minY
        }
        else {
            return 0
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

    var height: CGFloat {
        if let bounds = layer.bounds {
            return bounds.height > 0 ?  bounds.height : 1
        }
        else {
            return 1
        }
    }

    var body: some View {
        GeometryReader { proxy in

            let dataTransform = CGAffineTransform(scaleX: 1, y: -1)
                .translatedBy(x: 0, y: -proxy.frame(in: .local).height)
                .scaledBy(x: proxy.frame(in: .local).width / width,
                          y: proxy.frame(in: .local).height / height)
                .translatedBy(x: -minX, y: -minY)

            ForEach(layer.dataSets.indices, id: \.self) { lineIdx in
                let points = layer.dataSets[lineIdx].points
                if points.count > 0 {

                    Path { path in
                        path.move(to: points[0])
                        for j in 1..<points.count {
                            path.addLine(to: points[j])
                        }
                    }
                    .applying(dataTransform)
                    .stroke(layer.dataSets[lineIdx].color)
                }
            }
        }
    }

    init(_ layer: XYLayer) {
        self.layer = layer
    }
}
