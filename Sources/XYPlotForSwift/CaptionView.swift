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
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                HStack {
                    Rectangle().frame(width: 50, height: 2)
                    Text("Caption Line 1")
                }
                HStack {
                    Rectangle().frame(width: 50, height: 2)
                    Text("Caption Line 2")
                }
                HStack {
                    Rectangle().frame(width: 50, height: 2)
                    Text("Caption Line 3")
                }
                HStack {
                    Rectangle().frame(width: 50, height: 2)
                    Text("Caption Line 4")
                }
                HStack {
                    Rectangle().frame(width: 50, height: 2)
                    Text("Caption Line 5")
                }
            }
        }
    }

    init(_ layer: Binding<XYLayer>) {
        self._layer = layer
    }
}
