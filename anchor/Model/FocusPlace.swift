//
//  FocusPlace.swift
//  anchor
//

import CoreLocation
import SwiftData

/// How a place came to exist, which decides whether it belongs on the map.
enum PlaceSource: String, Codable {
    /// Created because a session was recorded here.
    case visited
    /// Found by arriving somewhere and looking it up. May be a study spot the
    /// user hasn't worked at yet, or a negative-cache row for somewhere that
    /// isn't one at all.
    case discovered
    /// Dropped by the user by hand.
    case userCreated
}

@Model
final class FocusPlace {
    @Attribute(.unique) var id: UUID

    var name: String
    /// Once the user renames a place, no lookup may overwrite `name` again.
    var isUserNamed: Bool

    var latitude: Double
    var longitude: Double
    var radius: Double

    /// `MKPointOfInterestCategory.rawValue`. Stored as a String because the
    /// category is a String-backed struct, not a persistable enum.
    var poiCategoryRaw: String?
    var source: PlaceSource

    var sessionCount: Int
    var totalFocusSeconds: Double
    var lastSessionAt: Date?
    var lastNotifiedAt: Date?

    // Sync-ready fields. Cheap now, a schema migration later.
    var remoteID: String?
    var updatedAt: Date
    var deletedAt: Date?

    /// `.nullify`, never `.cascade` — deleting a place the user no longer cares
    /// about must not take their focus history with it.
    @Relationship(deleteRule: .nullify, inverse: \FocusSession.place)
    var sessions: [FocusSession] = []

    init(
        name: String,
        coordinate: CLLocationCoordinate2D,
        source: PlaceSource,
        poiCategoryRaw: String? = nil,
        radius: Double = 100
    ) {
        self.id = UUID()
        self.name = name
        self.isUserNamed = false
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
        self.radius = radius
        self.poiCategoryRaw = poiCategoryRaw
        self.source = source
        self.sessionCount = 0
        self.totalFocusSeconds = 0
        self.updatedAt = .now
    }

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    var location: CLLocation {
        CLLocation(latitude: latitude, longitude: longitude)
    }

    /// True once this is somewhere the user actually works, as opposed to a
    /// place that was merely looked up. Drives what the map shows.
    var isRealPlace: Bool {
        sessionCount > 0 || source == .userCreated
    }

    // MARK: - Clustering

    /// Finds the nearest existing place within `radiusMeters`, or makes a new
    /// one. Nearest rather than first, so overlapping candidates resolve the
    /// same way every time.
    ///
    /// The scan is linear and in-memory on purpose: this is tens of rows, and
    /// a distance test can't live in a `#Predicate` — SwiftData can't call
    /// `CLLocation` methods and would trap at query time.
    static func findOrCreate(
        near coordinate: CLLocationCoordinate2D,
        in context: ModelContext,
        radiusMeters: Double = 100
    ) -> FocusPlace {
        let target = CLLocation(
            latitude: coordinate.latitude,
            longitude: coordinate.longitude
        )

        let existing = (try? context.fetch(FetchDescriptor<FocusPlace>())) ?? []

        let nearest = existing
            .filter { $0.deletedAt == nil }
            .map { ($0, $0.location.distance(from: target)) }
            .filter { $0.1 <= radiusMeters }
            .min { $0.1 < $1.1 }?
            .0

        if let nearest {
            return nearest
        }

        let place = FocusPlace(
            name: "Unnamed place",
            coordinate: coordinate,
            source: .visited
        )
        context.insert(place)
        return place
    }

    /// Pulls the stored coordinate toward the running mean of every session
    /// recorded here, so a geofence centres on where the user actually sits
    /// rather than wherever the first fix happened to land.
    func absorb(_ coordinate: CLLocationCoordinate2D) {
        let weight = Double(max(sessionCount, 0))
        let total = weight + 1

        latitude = (latitude * weight + coordinate.latitude) / total
        longitude = (longitude * weight + coordinate.longitude) / total
    }
}
