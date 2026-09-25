//
//  Dua.swift
//  remnd
//
//  Created by Shafayet Ul Islam on 24/9/2026.
//

import Foundation

struct Dua: Identifiable, Codable {
    let id: String
    let title: String
    let arabic: String
    let transliteration: String?
    let translation: String
    let benefit: String
}
