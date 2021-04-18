//
//  XYPlotView.swift
//
//
//  Created by Jim Hanson on 3/23/21.
//

import SwiftUI

///
///
///
struct XYPlotView: View {

    @State var model: XYPlotModel

    var body: some View {

        ZStack {

            PlotOverlayView($model)
                .background(Color.clear)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .zIndex(0.1)

            ForEach(model.layers.indices, id: \.self) { idx in
                if (model.layers[idx].showing) {
                    XYLayerView(model.layers[idx])
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }

    }
    
    init(_ dataSource: XYDataSource) {
        self._model = State(initialValue: XYPlotModel(dataSource))
    }

    init(_ dataSources: [XYDataSource]) {
        self._model = State(initialValue: XYPlotModel(dataSources))
    }
}
