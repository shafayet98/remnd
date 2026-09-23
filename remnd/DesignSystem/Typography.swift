//
//  Typography.swift
//  remnd
//
//  Created by Shafayet Ul Islam on 23/9/2026.
//

import SwiftUI

extension Font {
    // Arabic — relativeTo: keeps Dynamic Type scaling working
    static func arabic(_ size: CGFloat = 28) -> Font {
        .custom("GeezaPro", size: size, relativeTo: .title2)
    }
    static let arabicLarge = Font.custom("GeezaPro", size: 34, relativeTo: .title)

    // UI
    static let duaTitle = Font.system(.headline, design: .rounded, weight: .semibold)
    static let translation = Font.system(.body)
    static let transliteration = Font.system(.subheadline).italic()
    static let caption2Label = Font.system(.caption, weight: .medium)
}
