//
//  DuaCardItem.swift
//  remnd
//
//  Created by Shafayet Ul Islam on 24/9/2026.
//

import Foundation

struct DuaCardItem: Identifiable {
    let id: String

    let userDuaID: UUID
    let dua: Dua
    let repetitionIndex: Int
}
