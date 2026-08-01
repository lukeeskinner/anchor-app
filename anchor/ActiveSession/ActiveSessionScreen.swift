//
//  ActiveSessionScreen.swift
//  anchor
//

import CoreLocation
import MapKit
import SwiftData
import SwiftUI

struct ActiveSessionScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Environment(LocationService.self) private var location

    @State private var startDate = Date.now
    @State private var startCoordinate: CLLocationCoordinate2D?

    var body: some View {
        ZStack {
            CanvasBackground()

            VStack(spacing: 0) {
                Spacer()

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

                Spacer()

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
        }
        .navigationBarBackButtonHidden()
        .task {
            await location.requestWhenInUseIfNeeded()
            startCoordinate = await location.currentFix()
        }
    }

    private func endSession() {
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
}
