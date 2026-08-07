//
//  PlacesMap.swift
//  anchor
//

import MapKit
import SwiftData
import SwiftUI

/// The map of places the user actually works, with a permission card layered
/// over it when location isn't available.
struct PlacesMap: View {
    @Environment(LocationService.self) private var location

    @Query(filter: #Predicate<FocusPlace> { $0.deletedAt == nil })
    private var places: [FocusPlace]

    /// Only to tell "you haven't focused anywhere yet" apart from "you have
    /// sessions, but none of them carry a location".
    @Query(filter: #Predicate<FocusSession> { $0.deletedAt == nil })
    private var sessions: [FocusSession]

    @State private var camera = MapCameraPosition.automatic
    @State private var selectedID: UUID?

    /// Looked-up-but-never-worked-at rows exist as a lookup cache; they are not
    /// places the user studied, so they stay off the map.
    private var visible: [FocusPlace] {
        places.filter(\.isRealPlace)
    }

    private var selected: FocusPlace? {
        visible.first { $0.id == selectedID }
    }

    var body: some View {
        ZStack(alignment: .top) {
            if visible.isEmpty {
                empty
            } else {
                map
            }

            header
        }
        .navigationBarHidden(true)
        .sheet(item: Binding(get: { selected }, set: { selectedID = $0?.id })) { place in
            PlaceDetailSheet(place: place)
        }
    }

    private var map: some View {
        Map(position: $camera, selection: $selectedID) {
            ForEach(visible) { place in
                Marker(place.name, systemImage: icon(for: place), coordinate: place.coordinate)
                    .tint(Colors.primary)
                    .tag(place.id)
            }
        }
        // Apple's own POI labels fight the markers for attention; the places
        // the user works are the only thing this map is about.
        .mapStyle(.standard(pointsOfInterest: .excludingAll))
        .ignoresSafeArea()
    }

    private func icon(for place: FocusPlace) -> String {
        switch place.poiCategoryRaw {
        case MKPointOfInterestCategory.library.rawValue: "books.vertical.fill"
        case MKPointOfInterestCategory.cafe.rawValue: "cup.and.saucer.fill"
        default: place.source == .userCreated ? "mappin" : "scope"
        }
    }

    // MARK: - Overlays

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Places")
                .font(.system(size: 32, weight: .heavy))
                .tracking(-1)
                .foregroundStyle(Colors.onCanvas)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Colors.ink, in: Capsule())

            if let message = permissionMessage {
                permissionCard(message)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }

    private var permissionMessage: String? {
        if location.isDenied {
            "Location is off, so new sessions won't record where they happened."
        } else if location.authorization == .notDetermined {
            "Turn on location to start mapping where you focus best."
        } else {
            nil
        }
    }

    private func permissionCard(_ message: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(message)
                .font(.system(size: 14))
                .foregroundStyle(Colors.onCanvas)
                .fixedSize(horizontal: false, vertical: true)

            if location.isDenied {
                Button("Open Settings") { location.openSettings() }
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Colors.ink)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Color.white, in: Capsule())
                    .buttonStyle(.plain)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Colors.ink, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var emptyMessage: String {
        sessions.isEmpty
            ? "Finish a focus session and the place shows up here."
            : "Your earlier sessions were recorded before anchor could place them. New sessions will appear here."
    }

    private var empty: some View {
        ZStack {
            CanvasBackground()

            VStack(spacing: 12) {
                Image(systemName: "mappin.and.ellipse")
                    .font(.system(size: 34, weight: .light))
                    .foregroundStyle(Colors.onCanvas.opacity(0.8))

                Text(sessions.isEmpty ? "No places yet" : "No places recorded")
                    .font(.system(size: 26, weight: .heavy))
                    .tracking(-0.8)
                    .foregroundStyle(Colors.onCanvas)

                Text(emptyMessage)
                    .font(.subheadline)
                    .foregroundStyle(Colors.onCanvas.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            .padding(32)
        }
    }
}
