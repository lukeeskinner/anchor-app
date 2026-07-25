//
//  SettingsScreen.swift
//  anchor
//

import SwiftUI

struct SettingsScreen: View {
    var body: some View {
        FeaturePlaceholderView(
            title: "Settings",
            message: "Appearance, notifications, and session preferences will live here.",
            systemImage: "gearshape"
        )
    }
}

#Preview {
    NavigationStack {
        SettingsScreen()
    }
    .preferredColorScheme(.dark)
}
