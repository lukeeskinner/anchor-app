//
//  Colors.swift
//  anchor
//
//  Created by Luke Skinner on 7/11/26.
//

import SwiftUI

enum Colors {

    static let primary = Color(hex: 0x734B5E)

    static let secondary = Color(hex: 0x5B5250)

    static let accent = Color(hex: 0xD9A441)


    static let canvas = Color(hex: 0x734B5E)

    static let canvasLine = Color(hex: 0xFFFFFF, opacity: 0.07)

    static let onCanvas = Color(hex: 0xF7F1F3)

    static let ink = Color(hex: 0x241A1E)

    static let onInk = Color(hex: 0xA79AA0)

    static let background = Color(
        light: Color(hex: 0xF7F4F5),
        dark: Color(hex: 0x161114)
    )

    static let surface = Color(
        light: .white,
        dark: Color(hex: 0x241A1E)
    )

    static let surfaceTint = Color(
        light: Color(hex: 0xF1EAEC),
        dark: Color(hex: 0x2E2429)
    )

    static let textPrimary = Color(
        light: Color(hex: 0x241A1E),
        dark: Color(hex: 0xF5EFF1)
    )

    static let textSecondary = Color(
        light: Color(hex: 0x7A6C71),
        dark: Color(hex: 0xB5A7AC)
    )

    static let border = Color(
        light: Color(hex: 0xE7DDE0),
        dark: Color(hex: 0x3A2E33)
    )

    static let success = Color(hex: 0x6E8F6A)
    static let warning = Color(hex: 0xD9A441)
    static let error = Color(hex: 0xE2673C)
}


private extension Color {
    init(hex: UInt, opacity: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0,
            opacity: opacity
        )
    }

    init(light: Color, dark: Color) {
#if canImport(UIKit)
        self.init(
            UIColor { traits in
                traits.userInterfaceStyle == .dark
                    ? UIColor(dark)
                    : UIColor(light)
            }
        )
#elseif canImport(AppKit)
        self.init(
            NSColor(name: nil) { appearance in
                let isDark = appearance.bestMatch(
                    from: [.darkAqua, .aqua]
                ) == .darkAqua

                return isDark
                    ? NSColor(dark)
                    : NSColor(light)
            }
        )
#else
        self = light
#endif
    }
}
