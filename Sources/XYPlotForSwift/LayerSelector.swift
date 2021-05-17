//
//  LayerSelector.swift
//  ArcWorld
//
//  Created by Jim Hanson on 4/9/21.
//

import SwiftUI
import WacomaUI

public struct LayerSelector: View {

    @Binding var model: XYPlotModel

    @Environment(\.presentationMode) var presentationMode

    public var body: some View {
        VStack(alignment: .leading) {
            Text("Show:")
                .font(.headline)

            ForEach(model.layers.indices, id:\.self) { layerIdx in
                Button(action: { selectLayer(layerIdx) }) {
                    Text(model.layers[layerIdx].title)
                }
                .foregroundColor(UIConstants.controlColor)
                .modifier(SpanningButtonStyle())

            }
        }
    }

    public init(_ model: Binding<XYPlotModel>) {
        self._model = model
    }

    func selectLayer(_ layer: Int) {
        for idx in model.layers.indices {
            model.layers[idx].showing = (idx == layer)
        }
        presentationMode.wrappedValue.dismiss()
    }
}
