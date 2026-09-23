//
//  ArabicText.swift
//  remnd
//
//  Created by Shafayet Ul Islam on 23/9/2026.
//

import SwiftUI

struct ArabicText: View {
    let text: String
    var size: CGFloat = 28
    
    var body: some View {
        Text(text)
            .font(.arabic(size))
            .lineSpacing(size * 0.5)
            .multilineTextAlignment(.trailing)
            .environment(\.layoutDirection, .rightToLeft)
            .foregroundStyle(Color.textPrimary)
    }
}

#Preview {
    ArabicText(text:"بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ")
}
