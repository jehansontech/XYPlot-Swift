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
        HStack {
            VStack {
                Text("Caption Line 1")
                Text("Caption Line 2")
            }
            VStack {
                Text("Caption Line 3")
                Text("Caption Line 4")
                Text("Caption Line 5")
            }
        }
    }

    init(_ layer: Binding<XYLayer>) {
        self._layer = layer
    }
}
