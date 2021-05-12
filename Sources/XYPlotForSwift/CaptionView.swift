//
//  File.swift
//  
//
//  Created by Jim Hanson on 5/12/21.
//

import SwiftUI

struct CaptionView: View {

    @Binding var layer: XYLayer

    var body: some View {
        Text("CaptionView")
    }

    init(_ layer: Binding<XYLayer>) {
        self._layer = layer
    }
}
