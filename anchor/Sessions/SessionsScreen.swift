//
//  SessionsScreen.swift
//  anchor
//

import SwiftUI

struct SessionsScreen: View {
    var body: some View {
        FeaturePlaceholderView(
            title: "Sessions",
            message: "Your session history and active focus timers will live here.",
            systemImage: "timer"
        )
    }
}

#Preview {
    NavigationStack {
        SessionsScreen()
    }
    .preferredColorScheme(.dark)
}
