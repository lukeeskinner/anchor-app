//
//  ProfileScreen.swift
//  anchor
//

import SwiftUI

struct ProfileScreen: View {
    var body: some View {
        FeaturePlaceholderView(
            title: "Profile",
            message: "Your account details and personal focus goals will live here.",
            systemImage: "person.crop.circle"
        )
    }
}

#Preview {
    NavigationStack {
        ProfileScreen()
    }
    .preferredColorScheme(.dark)
}
