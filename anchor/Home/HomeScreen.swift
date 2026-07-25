//
//  HomeScreen.swift
//  anchor
//
//  Created by Luke Skinner on 7/16/26.
//

import SwiftUI

struct HomeViewState: Equatable {
    struct RecentSession: Identifiable, Equatable {
        let id: String
        let title: String
        let detail: String
        let duration: String
    }

    let greeting: String
    let subtitle: String
    let todayFocusMinutes: Int
    let completedSessions: Int
    let recentSessions: [RecentSession]

    static let empty = HomeViewState(
        greeting: "Welcome back",
        subtitle: "Ready to build a focused day?",
        todayFocusMinutes: 0,
        completedSessions: 0,
        recentSessions: []
    )
}

struct HomeScreen: View {
    let state: HomeViewState
    let onStartSession: () -> Void
    let onSeeAllSessions: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 34) {
                topBar
                intro
                startButton
                todaySection
                recentSection
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 28)
            .frame(maxWidth: 560)
            .frame(maxWidth: .infinity)
        }
        .background { CanvasBackground() }
        .navigationBarHidden(true)
    }

    // MARK: - Top

    private var topBar: some View {
        HStack(spacing: 14) {
            Text(Date.now, format: .dateTime.weekday(.wide).month(.abbreviated).day())
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Colors.onCanvas.opacity(0.75))

            Spacer(minLength: 0)

            Image(systemName: "person")
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(Colors.onCanvas)
                .frame(width: 42, height: 42)
                .background(Colors.ink, in: Circle())
                .accessibilityLabel("Profile")
        }
    }

    private var intro: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(state.greeting)
                .font(.system(size: 38, weight: .heavy))
                .tracking(-1.2)
                .foregroundStyle(Colors.onCanvas)
                .fixedSize(horizontal: false, vertical: true)

            Text(state.subtitle)
                .font(.subheadline)
                .foregroundStyle(Colors.onCanvas.opacity(0.72))
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: - Start

    private var startButton: some View {
        Button(action: onStartSession) {
            HStack(spacing: 9) {
                Image(systemName: "play.fill")
                    .font(.system(size: 14, weight: .bold))

                Text("Start a new session")
                    .font(.system(size: 17, weight: .bold))
            }
            .foregroundStyle(Colors.ink)
            .frame(maxWidth: .infinity)
            .frame(height: 58)
            .background(Color.white, in: Capsule())
        }
        .buttonStyle(.plain)
    }

    private var todaySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionTitle("Today")

            HStack(spacing: 12) {
                todayCard(
                    value: formattedMinutes(state.todayFocusMinutes),
                    label: "Focus time",
                    pillColor: Colors.accent
                )

                todayCard(
                    value: "\(state.completedSessions)",
                    label: "Completed",
                    pillColor: state.completedSessions == 0
                        ? Colors.border
                        : Colors.success
                )
            }
        }
    }

    private func todayCard(
        value: String,
        label: String,
        pillColor: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Colors.textSecondary)

            Text(value)
                .font(.system(size: 30, weight: .bold))
                .tracking(-0.8)
                .foregroundStyle(Colors.textPrimary)
                .padding(.top, 6)

            Spacer(minLength: 18)
        }
        .padding(18)
        .frame(maxWidth: .infinity, minHeight: 150, alignment: .leading)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    // MARK: - Recent

    private var recentSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .firstTextBaseline) {
                sectionTitle("Recent")

                Spacer()

                Button("See all", action: onSeeAllSessions)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Colors.ink)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 9)
                    .background(Color.white, in: Capsule())
                    .buttonStyle(.plain)
            }

            if state.recentSessions.isEmpty {
                emptyRecent
            } else {
                LazyVGrid(
                    columns: [GridItem(.flexible(), spacing: 12),
                              GridItem(.flexible(), spacing: 12)],
                    spacing: 12
                ) {
                    ForEach(state.recentSessions) { session in
                        recentCard(session)
                    }
                }
            }
        }
    }

    private var emptyRecent: some View {
        VStack(alignment: .leading, spacing: 10) {
            inkIcon("clock.arrow.circlepath")

            Text("No sessions yet")
                .font(.system(size: 19, weight: .bold))
                .tracking(-0.4)
                .foregroundStyle(Colors.onCanvas)

            Text("Finish a focus session and it will show up here.")
                .font(.system(size: 13))
                .foregroundStyle(Colors.onInk)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Colors.ink, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private func recentCard(_ session: HomeViewState.RecentSession) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                inkIcon("checkmark")

                Spacer()

                Text(session.duration)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Colors.onCanvas)
            }

            Text(session.title)
                .font(.system(size: 18, weight: .bold))
                .tracking(-0.4)
                .foregroundStyle(Colors.onCanvas)
                .fixedSize(horizontal: false, vertical: true)

            Text(session.detail)
                .font(.system(size: 12))
                .foregroundStyle(Colors.onInk)
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 150, alignment: .topLeading)
        .background(Colors.ink, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private func inkIcon(_ name: String) -> some View {
        Image(systemName: name)
            .font(.system(size: 15, weight: .medium))
            .foregroundStyle(Colors.onCanvas)
            .frame(width: 38, height: 38)
            .overlay(Circle().strokeBorder(Colors.onCanvas.opacity(0.28), lineWidth: 1))
            .accessibilityHidden(true)
    }

    // MARK: - Shared

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 32, weight: .heavy))
            .tracking(-1)
            .foregroundStyle(Colors.onCanvas)
    }

    private func formattedMinutes(_ minutes: Int) -> String {
        minutes >= 60
            ? "\(minutes / 60)h \(minutes % 60)m"
            : "\(minutes)m"
    }
}

#Preview("Empty") {
    NavigationStack {
        HomeScreen(
            state: .empty,
            onStartSession: {},
            onSeeAllSessions: {}
        )
    }
}

#Preview("Populated") {
    NavigationStack {
        HomeScreen(
            state: HomeViewState(
                greeting: "Welcome back",
                subtitle: "You focus best near the waterfront around 9 AM.",
                todayFocusMinutes: 95,
                completedSessions: 3,
                recentSessions: [
                    .init(id: "1", title: "Deep work", detail: "Ferry Building", duration: "50m"),
                    .init(id: "2", title: "Reading", detail: "Home desk", duration: "25m")
                ]
            ),
            onStartSession: {},
            onSeeAllSessions: {}
        )
    }
}
