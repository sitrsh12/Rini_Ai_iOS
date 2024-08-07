//
//  ContentView.swift
//  Rini_Ai_iOS
//
//  Created by sailesh adhikari on 01/08/24.
//

import SwiftUI

struct ContentView: View {
    @State private var text: String = ""
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
                        TextEditor(text: $text)
                        .frame(maxHeight: 250)
                        .padding(10)
                        .background(Color.white)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                        .padding()
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
