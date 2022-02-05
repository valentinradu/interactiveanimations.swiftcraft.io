//
//  File.swift
//
//
//  Created by Valentin Radu on 03/02/2022.
//

import Foundation
import SwiftUI

struct PresentedContentSizeKey: PreferenceKey {
    static var defaultValue: CGRect = .zero

    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

struct ScreenOutModifier: ViewModifier, Animatable {
    let edge: Edge
    var progress: Double
    @State private var rect: CGRect = .zero

    var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }

    func body(content: Content) -> some View {
        content
            .transformEffect(calculateAffineTransform())
            .overlay {
                GeometryReader { geo in
                    Color.clear
                        .preference(key: PresentedContentSizeKey.self,
                                    value: geo.frame(in: .global))
                }
                .onPreferenceChange(PresentedContentSizeKey.self) {
                    rect = $0
                }
            }
    }

    private func calculateAffineTransform() -> CGAffineTransform {
        let target: CGPoint
        switch edge {
        case .trailing:
            target = CGPoint(x: UIScreen.main.bounds.maxX, y: 0)
        case .leading:
            target = CGPoint(x: -rect.maxX, y: 0)
        case .top:
            target = CGPoint(x: 0, y: -rect.maxY)
        case .bottom:
            target = CGPoint(x: 0, y: UIScreen.main.bounds.maxY)
        }
        
        return .init(translationX: target.x * progress,
                     y: target.y * progress)
    }
}

extension AnyTransition {
    static func screenOut(edge: Edge) -> AnyTransition {
        AnyTransition.modifier(
            active: ScreenOutModifier(edge: edge, progress: 1),
            identity: ScreenOutModifier(edge: edge, progress: 0)
        )
    }
}

struct ScreenOut_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State var isPresented: Bool = true

        var body: some View {
            VStack {
                if isPresented {
                    Rectangle()
                        .fill(Color.red)
                        .frame(height: 400)
                        .transition(.screenOut(edge: .top))
                }
                Button(action: { isPresented.toggle() }) {
                    Text(verbatim: "Toggle")
                }
            }
            .animation(.easeInOut, value: isPresented)
        }
    }

    static var previews: some View {
        PreviewWrapper()
    }
}
