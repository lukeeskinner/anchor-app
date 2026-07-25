//
//  InsightsScreen.swift
//  anchor
//

import SwiftUI

struct InsightsScreen: View {
    var body: some View {
        FeaturePlaceholderView(
            title: "Insights",
            message: "Focus patterns and progress summaries will appear here.",
            systemImage: "chart.xyaxis.line"
        )
    }
}

#Preview {
    NavigationStack {
        InsightsScreen()
    }
    .preferredColorScheme(.dark)
}
