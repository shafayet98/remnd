# remnd

remnd is a SwiftUI iOS app for building a personal daily dua routine. Users enter through Sign in with Apple, choose duas and repetition counts, read through a card deck, and track their progress across local calendar days.

## Features

- **Home:** A daily deck shows Arabic text, transliteration, and a count of repetitions remaining. Arabic and transliteration tiles scroll for longer duas. The card flips to show the meaning and benefit; swiping right completes one card.
- **Discovery:** Browse the bundled dua catalog, open a full details page, and add a dua to the personal routine.
- **Profile:** Edit a username and bio, choose a color instead of a profile picture, view a 🍃 streak, and see 7-day card progress and a 30-day activity calendar.
- **New duas:** Enter a title, Arabic text, optional transliteration, meaning, and benefit. **Add to My Duas** saves it to the personal routine. **Publish for All** saves a pending submission and shows a confirmation.
- **Settings:** Reorder or remove personal duas and set how many times each should appear in the daily deck. Changes are saved explicitly.
- **Automatic theme:** The app uses a light gradient from 5:00 am through 5:00 pm local time and a dark palette from 5:01 pm through 4:59 am. Debug builds have a **Preview night theme** switch in Settings for testing during the day.

## Daily deck and streak

Each repetition is one card. Deck progress is saved on the device, so closing and reopening the app keeps the remaining cards. Changes to the routine update today's deck if no card has been completed; after the first card, they take effect on the next local day.

A day runs from local midnight to the following midnight. Completing every card in that day's deck adds one streak day, at most once per day. The existing streak remains visible while the next day is still in progress. If that day ends without a completed deck, the streak resets to zero. A new daily deck starts after midnight or when the app becomes active on a new day.

## Sign-in prototype

The iOS app presents Apple's native sign-in button and checks the saved Apple credential when it reopens. After a successful Apple authorization, the app opens Home and keeps each Apple user's local data separate. The first Apple account used on an existing installation receives the earlier device-only data. Sign Out is available on Profile. Debug simulator builds also offer **Preview without signing in**, which uses the existing device-local data and is absent from release builds.

There is no authentication backend yet. The Apple credential is **not** verified by a server, and this local sign-in does not provide cloud sync or a server session. Before releasing account-backed features, connect the Apple identity token and authorization code to a backend that verifies them and manages sessions.

## Current scope

The catalog and initial routine are seeded from `MockData`. Profile details, custom duas, pending submissions, routine settings, and daily activity are stored locally with `UserDefaults`. There is no cross-device sync yet.

Public submission is a local pending state only: the app does not send a dua to a reviewer, approve it, or add it to Discovery. A backend and review workflow are needed for public publishing.

## Run the project

Open `remnd.xcodeproj` in Xcode, select the `remnd` scheme, and run it on an iPhone simulator or device. The project currently targets iOS 26.4 and needs an Xcode installation with that SDK.

To try Apple sign-in in a signed build, use a development team that supports Sign in with Apple and ensure the app's identifier and provisioning profile include the capability. Personal development teams do not support it.

The app starts at `remndApp` → `ContentView`, which shows Login until Apple authorization succeeds and then opens `RootTabView` with **Home** selected. The root view owns the shared `AppDataStore`; `DeckBuilder` expands each selected dua into its requested number of cards. Unit tests in `remndTests` cover local-day streak behavior, saved progress, and next-day configuration changes.
