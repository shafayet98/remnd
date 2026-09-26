import SwiftUI

struct AppPalette {
    let isDaytime: Bool

    init(date: Date, calendar: Calendar = .autoupdatingCurrent) {
        let time = calendar.dateComponents([.hour, .minute], from: date)
        let minutesSinceMidnight = (time.hour ?? 0) * 60 + (time.minute ?? 0)
        isDaytime = (5 * 60...17 * 60).contains(minutesSinceMidnight)
    }

    private static func color(_ hex: UInt32) -> Color {
        Color(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }

    var background: AnyShapeStyle {
        if isDaytime {
            AnyShapeStyle(
                LinearGradient(
                    colors: [Self.color(0xE3D5FF), Self.color(0xFFC4B8), Self.color(0xFFE7C2)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        } else {
            AnyShapeStyle(Self.color(0x0F1512))
        }
    }

    var card: Color { isDaytime ? Self.color(0xFFFFFF) : Self.color(0x161E1A) }
    var cardBorder: Color { isDaytime ? Self.color(0xF4D9CF) : Self.color(0x26332C) }
    var hintText: Color { isDaytime ? Self.color(0xA07D78) : Self.color(0x6F8278) }
    var primaryText: Color { isDaytime ? Self.color(0x38242B) : Self.color(0xE9F5EC) }

    var arabicTile: Color { isDaytime ? Self.color(0xFFE9DF) : Self.color(0x1F3329) }
    var arabicText: Color { isDaytime ? Self.color(0x5A1F2E) : Self.color(0xE9F5EC) }
    var transliterationTile: Color { isDaytime ? Self.color(0xF5EEFF) : Self.color(0x1B2420) }
    var transliterationText: Color { isDaytime ? Self.color(0x3E2F63) : Self.color(0xB9C7BF) }
    var meaningTile: Color { isDaytime ? Self.color(0xF5EEFF) : Self.color(0x1B2420) }
    var meaningText: Color { isDaytime ? Self.color(0x3E2F63) : Self.color(0xB9C7BF) }

    var counter: Color { isDaytime ? Self.color(0xD9466F) : Self.color(0xE2B04A) }
    var counterText: Color { isDaytime ? Self.color(0xFFFFFF) : Self.color(0x241800) }
    var smallButton: Color { isDaytime ? Self.color(0xFFE1E6) : Self.color(0x22362B) }
    var smallButtonIcon: Color { isDaytime ? Self.color(0xA3304F) : Self.color(0x9FD8B3) }

    var navigationBar: Color { isDaytime ? Self.color(0xFFFFFF) : Self.color(0x161E1A) }
    var tabBarSurround: Color { isDaytime ? Self.color(0xFFE7C2) : Self.color(0x0F1512) }
    var activeTab: Color { isDaytime ? Self.color(0xD9466F) : Self.color(0xE2B04A) }
    var inactiveTab: Color { isDaytime ? Self.color(0x7A6468) : Self.color(0x8A9A91) }
}

private struct AppPaletteKey: EnvironmentKey {
    static let defaultValue = AppPalette(date: .now)
}

extension EnvironmentValues {
    var appPalette: AppPalette {
        get { self[AppPaletteKey.self] }
        set { self[AppPaletteKey.self] = newValue }
    }
}
