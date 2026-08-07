//
//  ActiveSessionScreen.swift
//  anchor
//

import CoreLocation
import MapKit
import SwiftData
import SwiftUI

struct ActiveSessionScreen: View {
    /// A session only counts once anchor knows where it's happening, so the
    /// clock doesn't start until a fix lands.
    private enum Phase {
        case locating
        case running
        case unavailable
    }

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Environment(LocationService.self) private var location

    @State private var phase = Phase.locating
    @State private var startDate = Date.now
    @State private var startCoordinate: CLLocationCoordinate2D?

    var body: some View {
        ZStack {
            CanvasBackground()

            VStack(spacing: 0) {
                Spacer()

                switch phase {
                case .locating: locating
                case .running, .unavailable: clock
                }

                Spacer()

                if phase == .running {
                    endButton
                }
            }

            if phase == .unavailable {
                unavailableSheet
            }
        }
        .navigationBarBackButtonHidden()
        .task { await resolveLocation() }
    }

    // MARK: - States

    private var locating: some View {
        VStack(spacing: 14) {
            ProgressView()
                .tint(Colors.onCanvas)

            Text("Finding your location")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(Colors.onCanvas)

            Text("Your session starts once anchor knows where you are.")
                .font(.system(size: 14))
                .foregroundStyle(Colors.onCanvas.opacity(0.65))
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 40)
    }

    private var clock: some View {
        VStack(spacing: 0) {
            Text("Focusing")
                .font(.system(size: 15, weight: .bold))
                .tracking(0.4)
                .foregroundStyle(Colors.onCanvas.opacity(0.7))

            Text(
                timerInterval: startDate...startDate.addingTimeInterval(86_400),
                countsDown: false
            )
            .font(.system(size: 68, weight: .heavy))
            .tracking(-2)
            .foregroundStyle(Colors.onCanvas)
            .padding(.top, 10)

            Text("Started \(startDate, format: .dateTime.hour().minute())")
                .font(.system(size: 14))
                .foregroundStyle(Colors.onCanvas.opacity(0.6))
                .padding(.top, 12)
        }
    }

    private var endButton: some View {
        Button(action: endSession) {
            Text("End session")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(Colors.ink)
                .frame(maxWidth: .infinity)
                .frame(height: 58)
                .background(Color.white, in: Capsule())
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 20)
        .padding(.bottom, 24)
    }

    // MARK: - No location

    /// Deliberately blocking. A session anchor can't place teaches it nothing,
    /// so it's better to say so now than to discard an hour of work later.
    private var unavailableSheet: some View {
        ZStack {
            Colors.ink.opacity(0.55)
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                Image(systemName: "location.slash")
                    .font(.system(size: 26, weight: .medium))
                    .foregroundStyle(Colors.onCanvas)

                Text(location.isDenied ? "Location is off" : "Can't find you")
                    .font(.system(size: 26, weight: .heavy))
                    .tracking(-0.8)
                    .foregroundStyle(Colors.onCanvas)
                    .padding(.top, 16)

                Text(explanation)
                    .font(.system(size: 15))
                    .foregroundStyle(Colors.onInk)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 8)

                Button(action: primaryAction) {
                    Text(location.isDenied ? "Open Settings" : "Try again")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Colors.ink)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color.white, in: Capsule())
                }
                .buttonStyle(.plain)
                .padding(.top, 24)

                Button("Go back") { dismiss() }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Colors.onInk)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .buttonStyle(.plain)
                    .padding(.top, 4)
            }
            .padding(28)
            .background(
                Colors.ink,
                in: RoundedRectangle(cornerRadius: 28, style: .continuous)
            )
            .padding(.horizontal, 28)
        }
    }

    private var explanation: String {
        location.isDenied
            ? "Anchor maps the places you focus best, so it needs your location to record a session. Turn it on in Settings."
            : "Anchor couldn't get a location fix, so this session wouldn't be recorded. Check that location is available and try again."
    }

    private func primaryAction() {
        if location.isDenied {
            location.openSettings()
        } else {
            Task { await resolveLocation() }
        }
    }

    // MARK: - Actions

    private func resolveLocation() async {
        phase = .locating

        await location.requestWhenInUseIfNeeded()

        guard location.canReadLocation,
              let fix = await location.currentFix()
        else {
            phase = .unavailable
            return
        }

        startCoordinate = fix
        // The clock starts here, not on appear, so elapsed time matches what
        // actually gets recorded.
        startDate = .now
        phase = .running
    }

    /// Not `.onDisappear` — that also fires on a swipe back, which would record
    /// the session twice.
    private func endSession() {
        guard let startCoordinate else {
            dismiss()
            return
        }

        let session = FocusSession.record(
            start: startDate,
            end: .now,
            coordinate: startCoordinate,
            in: context
        )

        if let place = session.place, !place.isUserNamed {
            Task { await name(place) }
        }

        dismiss()
    }

    /// Names a place the first time anchor sees it. Never overwrites a name the
    /// user chose themselves.
    private func name(_ place: FocusPlace) async {
        guard let found = await PlaceLookup.lookup(place.coordinate) else { return }
        guard !place.isUserNamed else { return }

        place.name = found.name
        place.poiCategoryRaw = found.category?.rawValue
        place.updatedAt = .now
        try? context.save()
    }
}

#Preview {
    NavigationStack {
        ActiveSessionScreen()
    }
    .environment(LocationService())
    .modelContainer(for: [FocusSession.self, FocusPlace.self], inMemory: true)
}
