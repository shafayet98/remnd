//
//  UserDua.swift
//  remnd
//
//  Created by Shafayet Ul Islam on 24/9/2026.
//

import Foundation

struct UserDua: Identifiable, Codable, Equatable {
    let id: UUID
    let duaID: String

    var repetitionCount: Int
    var position: Int
}
