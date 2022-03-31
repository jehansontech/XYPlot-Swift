//
//  CaptionView.swift
//  XYPlotForSwift
//
//  Created by Jim Hanson on 5/12/21.
//

import SwiftUI

struct CaptionView: View {

    @ObservedObject var model: XYPlotModel

    var body: some View {
        Text(model.caption)
            .multilineTextAlignment(.trailing)
            .frame(maxWidth: .infinity, alignment: .trailing)
    }

    init(_ model: XYPlotModel) {
        self.model = model
    }
}
