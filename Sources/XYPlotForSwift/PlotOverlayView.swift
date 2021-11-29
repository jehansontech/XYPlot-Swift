////
////  PlotOverlayView.swift
////  ArcWorld
////
////  Created by Jim Hanson on 4/9/21.
////
//
//import SwiftUI
//import WacomaUI
//
//public struct PlotOverlayView: View {
//
//    @Binding var model: XYPlotModel
//
//    @State var layerSelectorShowing: Bool = false
//
//    public var body: some View {
//
//        HStack(alignment: .top) {
//
//            Spacer()
//
//            // right edge VStack
//            VStack {
//
//                // right-side buttons
//                VStack(spacing: UIConstants.buttonSpacing) {
//
//                    // Layers button
//                    Button(action: {
//                        self.layerSelectorShowing = true
//                    }) {
//                        // hammer
//                        // wrench
//                        Image(systemName: "wrench")
//                    }
//                    .modifier(SymbolButtonStyle())
//                    .foregroundColor(UIConstants.controlColor)
//                    .popover(isPresented: $layerSelectorShowing) {
//                        LayerSelector($model)
//                            .modifier(PopStyle())
//                    }
//                    // end Layers button
//                }
//                // end right-side buttons
//
//                Spacer()
//            }
//            // end right edge VStack
//        }
//        // end outermost HStack
//    }
//
//    init(_ model: Binding<XYPlotModel>) {
//        self._model = model
//    }
//}
