//
//  AnchorStore.swift
//  anchor
//

import SwiftData

/// The app's single SwiftData container.
///
/// Held explicitly rather than left to `.modelContainer(for:)` because two
/// things need the *same* container: the SwiftUI view tree, and the location
/// service, which has to write during a background wake before any view exists.
enum AnchorStore {
    static let container: ModelContainer = {
        do {
            return try ModelContainer(for: FocusSession.self, FocusPlace.self)
        } catch {
            fatalError("Could not create the SwiftData container: \(error)")
        }
    }()
}
