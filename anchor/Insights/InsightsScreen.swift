//
//  InsightsScreen.swift
//  anchor
//

import SwiftData
import SwiftUI

struct InsightsScreen: View {
    var body: some View {
        PlacesMap()
    }
}

#Preview {
    NavigationStack {
        InsightsScreen()
    }
    .environment(LocationService())
    .modelContainer(for: [FocusSession.self, FocusPlace.self], inMemory: true)
}
