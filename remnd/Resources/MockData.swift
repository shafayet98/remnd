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
            id: "ayatul-kursi",
            title: "Ayatul Kursi · Al-Baqarah 2:255",
            arabic: "اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ ۚ لَهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ ۗ مَنْ ذَا الَّذِي يَشْفَعُ عِنْدَهُ إِلَّا بِإِذْنِهِ ۚ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ ۖ وَلَا يُحِيطُونَ بِشَيْءٍ مِنْ عِلْمِهِ إِلَّا بِمَا شَاءَ ۚ وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالْأَرْضَ ۖ وَلَا يَئُودُهُ حِفْظُهُمَا ۚ وَهُوَ الْعَلِيُّ الْعَظِيمُ",
            transliteration: """
            Allāhu lā ilāha illā huwa, al-Ḥayyul-Qayyūm. Lā ta’khudhuhu sinatun wa lā nawm. Lahū mā fis-samāwāti wa mā fil-arḍ. Man dhal-ladhī yashfa’u ‘indahū illā bi-idhnih? Ya’lamu mā bayna aydīhim wa mā khalfahum, wa lā yuḥīṭūna bi-shay’im-min ‘ilmihī illā bimā shā’. Wasi’a kursiyyuhus-samāwāti wal-arḍ, wa lā ya’ūduhu ḥifẓuhumā, wa huwal-‘Aliyyul-‘Aẓīm.
            """,
            translation: "This verse affirms Allah’s oneness and describes Him as the Ever-Living and Sustainer. Everything in the heavens and earth belongs to Him. Intercession occurs only by His permission. His knowledge encompasses all things, and His Kursi extends over the heavens and earth. Preserving them does not burden Him. He is the Most High, the Greatest.",
            benefit: "A verse of remembrance describing Allah’s oneness, life, sustaining power, knowledge, authority, and greatness. (Qur’an 2:255)"
        ),

        Dua(
            id: "subhanallah",
            title: "SubhanAllah",
            arabic: "سُبْحَانَ اللَّهِ",
            transliteration: "SubhanAllah",
            translation: "Glory be to Allah",
            benefit: "A phrase of remembrance that declares Allah free from imperfection."
        ),

        Dua(
            id: "alhamdulillah",
            title: "Alhamdulillah",
            arabic: "الْحَمْدُ لِلَّهِ",
            transliteration: "Alhamdulillah",
            translation: "All praise is due to Allah",
            benefit: "A phrase of remembrance expressing praise and gratitude to Allah."
        ),

        Dua(
            id: "allahuakbar",
            title: "Allahu Akbar",
            arabic: "اللَّهُ أَكْبَرُ",
            transliteration: "Allahu Akbar",
            translation: "Allah is the Greatest",
            benefit: "A phrase of remembrance affirming the greatness of Allah."
        ),

        Dua(
            id: "astaghfirullah",
            title: "Astaghfirullah",
            arabic: "أَسْتَغْفِرُ اللَّهَ",
            transliteration: "Astaghfirullah",
            translation: "I seek forgiveness from Allah",
            benefit: "A remembrance expressing a request for Allah’s forgiveness."
        )
    ]

    static let userDuas: [UserDua] = [
        UserDua(
            id: UUID(),
            duaID: "ayatul-kursi",
            repetitionCount: 1,
            position: 0
        ),

        UserDua(
            id: UUID(),
            duaID: "subhanallah",
            repetitionCount: 1,
            position: 1
        ),

        UserDua(
            id: UUID(),
            duaID: "alhamdulillah",
            repetitionCount: 3,
            position: 2
        ),

        UserDua(
            id: UUID(),
            duaID: "allahuakbar",
            repetitionCount: 3,
            position: 3
        )
    ]
}
