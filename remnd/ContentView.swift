//
//  ContentView.swift
//  remnd
//
//  Created by Shafayet Ul Islam on 19/9/2026.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            Color(.appBackground)
                .ignoresSafeArea()
            VStack{
                Image(.appLogo)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120)
            }
        }
    }
}

#Preview {
    ContentView()
}
