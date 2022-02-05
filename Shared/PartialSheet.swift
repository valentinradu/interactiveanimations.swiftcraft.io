//
//  PartialSheet.swift
//  InteractiveAnimations
//
//  Created by Valentin Radu on 04/02/2022.
//

import Foundation
import SwiftUI

struct CornerRadiusShape: Shape {
    let radius: Double
    let corners: UIRectCorner

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

private struct InlineSheetProgressModifier<C: View>: ViewModifier, Animatable {
    var progress: Double
    private let contentBuilder: () -> C

    var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }

    init(progress: Double, @ViewBuilder content: @escaping () -> C) {
        self.contentBuilder = content
        self.progress = progress
    }

    func body(content: Content) -> some View {
        content
            .cornerRadius(progress * 20)
            .offset(y: progress * 20)
            .rotation3DEffect(.degrees(progress * -10),
                              axis: (x: 1, y: 0, z: 0),
                              anchor: .init(x: 0.5, y: 0.2),
                              anchorZ: progress * 60,
                              perspective: 1)
            .overlay {
                if progress > 0.01 {
                    contentBuilder()
                        .clipShape(CornerRadiusShape(radius: 10, corners: [.topRight, .topLeft]))
                        .padding(.top, 75)
                        .modifier(ScreenOutModifier(edge: .bottom, progress: 1 - progress))
                }
            }
    }
}

private struct DynamicParameters: Equatable {
    var translation: Double = 0
    var delta: Double = 0
}

private struct InlineSheetModifier<C: View>: ViewModifier {
    private let contentBuilder: () -> C
    @Binding var isPresented: Bool
    @State private var progress: Double = 0
    @GestureState private var dynamics: DynamicParameters = .init()

    init(isPresented: Binding<Bool>, @ViewBuilder content: @escaping () -> C) {
        self.contentBuilder = content
        _isPresented = isPresented
    }

    func body(content: Content) -> some View {
        content
            .modifier(InlineSheetProgressModifier(progress: progress,
                                                  content: contentBuilder))
            .onChange(of: isPresented) { value in
                withAnimation(.easeInOut) {
                    progress = value ? 1 : 0
                }
            }
            .onChange(of: dynamics) {
                if $0.delta == 0 {
                    return
                }

                let candidate = progress - $0.delta / UIScreen.main.bounds.height
                if candidate > 0, candidate < 1 {
                    var transaction = Transaction()
                    transaction.isContinuous = true
                    transaction.animation = .interpolatingSpring(stiffness: 30, damping: 20)
                    withTransaction(transaction) {
                        progress = candidate
                    }
                }
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .updating($dynamics) { value, state, _ in
                        if state.translation > 0 {
                            state.delta = value.translation.height - state.translation
                            state.translation = value.translation.height
                        }
                        else {
                            state.translation = value.translation.height
                        }
                    }
                    .onEnded { _ in
                        withAnimation(.easeInOut(duration: 0.25)) {
                            if progress < 0.7 {
                                isPresented = false
                                progress = 0
                            }
                            else {
                                isPresented = true
                                progress = 1
                            }
                        }
                    }
            )
    }
}

extension View {
    func inlineSheet<V: View>(isPresented: Binding<Bool>,
                              @ViewBuilder content: @escaping () -> V) -> some View
    {
        modifier(InlineSheetModifier(isPresented: isPresented, content: content))
    }
}
