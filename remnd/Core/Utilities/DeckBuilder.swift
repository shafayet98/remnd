//
//  DeckBuilder.swift
//  remnd
//
//  Created by Shafayet Ul Islam on 24/9/2026.
//


import Foundation

enum DeckBuilder {

    static func build(
        userDuas: [UserDua],
        duas: [Dua]
    ) -> [DuaCardItem] {

        let duaLookup = Dictionary(
            uniqueKeysWithValues: duas.map { ($0.id, $0) }
        )

        return userDuas
            .sorted { $0.position < $1.position }
            .flatMap { userDua in

                guard
                    let dua = duaLookup[userDua.duaID],
                    userDua.repetitionCount > 0
                else {
                    return [DuaCardItem]()
                }

                return (1...userDua.repetitionCount).map {
                    index in

                    DuaCardItem(
                        id: "\(userDua.id)-\(index)",
                        userDuaID: userDua.id,
                        dua: dua,
                        repetitionIndex: index
                    )
                }
            }
    }
}
