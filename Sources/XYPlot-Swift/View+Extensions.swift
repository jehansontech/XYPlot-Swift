//
//  View+Extensions.swift
//  ArcWorld
//
//  Created by Jim Hanson on 4/9/21.
//

import SwiftUI

///
/// cf. https://stackoverflow.com/questions/58494193/swiftui-rotationeffect-framing-and-offsetting
///
private struct SizeKey: PreferenceKey {
    static let defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

struct Rotated: ViewModifier {

    var angle: Angle

    @State private var size: CGSize = .zero

    func body(content: Content) -> some View {

        // Rotate the frame, and compute the smallest integral frame that contains it
        let newFrame = CGRect(origin: .zero, size: size)
            .offsetBy(dx: -size.width/2, dy: -size.height/2)
            .applying(.init(rotationAngle: CGFloat(angle.radians)))
            .integral

        return content
            .fixedSize()                    // Don't change the view's ideal frame
            .captureSize(in: $size)         // Capture the size of the view's ideal frame
            .rotationEffect(angle)          // Rotate the view
            .frame(width: newFrame.width,   // And apply the new frame
                   height: newFrame.height)

    }

    init(_ angle: Angle) {
        self.angle = angle
    }
}

//    struct Rotated<Rotated: View>: View {
//        var view: Rotated
//        var angle: Angle
//
//        init(_ view: Rotated, angle: Angle = .degrees(-90)) {
//            self.view = view
//            self.angle = angle
//        }
//
//        @State private var size: CGSize = .zero
//
//        var body: some View {
//            // Rotate the frame, and compute the smallest integral frame that contains it
//            let newFrame = CGRect(origin: .zero, size: size)
//                .offsetBy(dx: -size.width/2, dy: -size.height/2)
//                .applying(.init(rotationAngle: CGFloat(angle.radians)))
//                .integral
//
//            return view
//                .fixedSize()                    // Don't change the view's ideal frame
//                .captureSize(in: $size)         // Capture the size of the view's ideal frame
//                .rotationEffect(angle)          // Rotate the view
//                .frame(width: newFrame.width,   // And apply the new frame
//                       height: newFrame.height)
//        }
//    }

extension View {

    func captureSize(in binding: Binding<CGSize>) -> some View {
        overlay(GeometryReader { proxy in
            Color.clear.preference(key: SizeKey.self, value: proxy.size)
        })
        .onPreferenceChange(SizeKey.self) { size in binding.wrappedValue = size }
    }

    func rotated(by angle: Angle) -> some View {
        self.modifier(Rotated(angle))
    }
}

