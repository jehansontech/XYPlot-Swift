//
//  LayerSelector.swift
//  ArcWorld
//
//  Created by Jim Hanson on 4/9/21.
//

import SwiftUI
import UIStuff

struct LayerSelector: View {

    @Binding var model: XYPlotModel

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack(alignment: .leading) {
            Text("Show:")
                .font(.headline)

            ForEach(model.layers.indices, id:\.self) { layerIdx in
                let showing = model.layers[layerIdx].showing
                Button(action: { selectLayer(layerIdx) }) {
                    HStack {
                        Image(systemName: showing ? "checkmark.circle": "circle")
                            .imageScale(.large)
                            .foregroundColor(UIConstants.controlColor)
                            .frame(minWidth: UIConstants.symbolButtonWidth, minHeight: UIConstants.symbolButtonHeight)
                        Text(model.layers[layerIdx].title)
                    }
                }
            }
        }
    }

    func selectLayer(_ layer: Int) {
        for idx in model.layers.indices {
            model.layers[idx].showing = (idx == layer)
        }
        presentationMode.wrappedValue.dismiss()
    }
}
