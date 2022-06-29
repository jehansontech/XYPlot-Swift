//
//  XYPlotView.swift
//  XYPlotForSwift
//
//  Created by Jim Hanson on 3/23/21.
//

import SwiftUI
import Wacoma

public struct XYPlotView: View {
    
    @ObservedObject var model: XYPlotModel

    public var body: some View {
        VStack(spacing: 0) {
            
            if model.hasTitle {
                Text(model.title)
                    .font(.headline)
                    .frame(maxWidth: .infinity, minHeight: XYPlotConstants.titleHeight)
                    .padding(.bottom, 10)
            }
            
            if let selectedLayer = model.selectedLayer {
                
                Text(model.layers[selectedLayer].title)
                    .font(.headline)
                    .frame(maxWidth: .infinity, minHeight: XYPlotConstants.titleHeight)
                    .padding(.bottom, 10)
                
                
                HStack(spacing: 0) {
                    YAxisView(model.layers[selectedLayer])
                        .frame(width: XYPlotConstants.yAxisLabelsWidth)
                    LayerView(model.layers[selectedLayer])
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .border(Color.gray)
                    Spacer()
                        .frame(width: XYPlotConstants.yAxisLabelsWidth)
                }
                
                HStack(spacing: 0) {
                    Spacer()
                        .frame(width: XYPlotConstants.yAxisLabelsWidth)
                    XAxisView(model.layers[selectedLayer])
                        .frame(height: XYPlotConstants.xAxisLabelsHeight)
                    Spacer()
                        .frame(width: XYPlotConstants.yAxisLabelsWidth)
                }
                
                HStack(alignment: .top, spacing: 0) {
                    Spacer()
                        .frame(width: XYPlotConstants.yAxisLabelsWidth)
                    LegendView(model.layers[selectedLayer])
                    Spacer().frame(width: 20)
                    CaptionView(model)
                    Spacer()
                        .frame(width: XYPlotConstants.yAxisLabelsWidth)
                }
            }
            else {
                Text("No Data")
                    .font(.title)
                    .foregroundColor(.gray)
            }
        }
    }
    
    public init(_ model: XYPlotModel) {
        // print("XYPlotView.init selectedLayer=\(String(describing: model.selectedLayer))")
        self.model = model
    }
}

