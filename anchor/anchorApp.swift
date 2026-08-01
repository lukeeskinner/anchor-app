//
//  anchorApp.swift
//  anchor
//
//  Created by Luke Skinner on 7/11/26.
//

import SwiftData
import SwiftUI

@main
struct anchorApp: App {
    @AppStorage("appAppearance") private var appAppearance = AppAppearance.dark
    @State private var location = LocationService()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(location)
                .preferredColorScheme(appAppearance.colorScheme)
        }
        .modelContainer(AnchorStore.container)
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
