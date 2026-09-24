//
//  MockData.swift
//  remnd
//
//  Created by Shafayet Ul Islam on 24/9/2026.
//


import Foundation

enum MockData {

    static let duas: [Dua] = [
        Dua(
            id: "subhanallah",
            title: "SubhanAllah",
            arabic: "سُبْحَانَ اللَّهِ",
            transliteration: "SubhanAllah",
            translation: "Glory be to Allah"
        ),

        Dua(
            id: "alhamdulillah",
            title: "Alhamdulillah",
            arabic: "الْحَمْدُ لِلَّهِ",
            transliteration: "Alhamdulillah",
            translation: "All praise is due to Allah"
        ),

        Dua(
            id: "allahuakbar",
            title: "Allahu Akbar",
            arabic: "اللَّهُ أَكْبَرُ",
            transliteration: "Allahu Akbar",
            translation: "Allah is the Greatest"
        )
    ]

    static let userDuas: [UserDua] = [
        UserDua(
            id: UUID(),
            duaID: "subhanallah",
            repetitionCount: 1,
            position: 0
        ),

        UserDua(
            id: UUID(),
            duaID: "alhamdulillah",
            repetitionCount: 3,
            position: 1
        ),

        UserDua(
            id: UUID(),
            duaID: "allahuakbar",
            repetitionCount: 3,
            position: 2
        )
    ]
}
