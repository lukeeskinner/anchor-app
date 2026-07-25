//
//  anchorApp.swift
//  anchor
//
//  Created by Luke Skinner on 7/11/26.
//

import SwiftUI

@main
struct anchorApp: App {
    @AppStorage("appAppearance") private var appAppearance = AppAppearance.dark

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(appAppearance.colorScheme)
        }
    }
}

private enum AppAppearance: String {
    case dark
    case light
    case system

    var colorScheme: ColorScheme? {
        switch self {
        case .dark: .dark
        case .light: .light
        case .system: nil
        }
    }
}
