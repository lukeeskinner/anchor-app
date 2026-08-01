//
//  HomeTabView.swift
//  anchor
//

import SwiftData
import SwiftUI

/// Feeds the real store into `HomeScreen`, which stays purely presentational.
///
/// All of `HomeViewState`'s pre-formatted strings are built here, so the view
/// itself never learns that SwiftData exists.
struct HomeTabView: View {
    let onStartSession: () -> Void
    let onSeeAllSessions: () -> Void

    @Query(
        filter: #Predicate<FocusSession> { $0.deletedAt == nil },
        sort: \FocusSession.start,
        order: .reverse
    )
    private var sessions: [FocusSession]

    var body: some View {
        HomeScreen(
            state: state,
            onStartSession: onStartSession,
            onSeeAllSessions: onSeeAllSessions
        )
    }

    private var state: HomeViewState {
        let today = sessions.filter {
            Calendar.current.isDateInToday($0.start)
        }

        return HomeViewState(
            greeting: HomeViewState.empty.greeting,
            subtitle: HomeViewState.empty.subtitle,
            todayFocusMinutes: Int(
                today.reduce(0) { $0 + $1.duration } / 60
            ),
            completedSessions: today.count,
            recentSessions: sessions.prefix(4).map(Self.card)
        )
    }

    private static func card(
        for session: FocusSession
    ) -> HomeViewState.RecentSession {
        HomeViewState.RecentSession(
            id: session.id.uuidString,
            title: session.start.formatted(
                .dateTime.weekday(.abbreviated).hour().minute()
            ),
            detail: session.place?.name ?? "Location off",
            duration: "\(Int(session.duration / 60))m"
        )
    }
}
