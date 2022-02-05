//
//  InteractiveAnimationsApp.swift
//  Shared
//
//  Created by Valentin Radu on 04/02/2022.
//

import SwiftUI

@main
struct InteractiveAnimationsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @State var isPresented: Bool = false
    @State var isPresented2: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(.gray)
                .inlineSheet(isPresented: $isPresented) {
                    Rectangle()
                        .fill(.pink)
//                        .inlineSheet(isPresented: $isPresented2) {
//                            Rectangle()
//                                .fill(.yellow)
//                        }
                }
            HStack {
                Spacer()
                Button(action: { isPresented.toggle() }) {
                    Text(verbatim: "Toggle")
                        .foregroundColor(.white)
                        .fontWeight(.medium)
                        .textCase(.uppercase)
                }
                Spacer()
            }
            .padding(20)
            .background(.blue)
        }
    }
}

struct InlineSheetModifier_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
