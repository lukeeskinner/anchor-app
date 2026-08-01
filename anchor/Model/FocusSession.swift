//
//  FocusSession.swift
//  anchor
//

import CoreLocation
import SwiftData

@Model
final class FocusSession {
    @Attribute(.unique) var id: UUID

    var start: Date
    var end: Date

    /// Optional: a session run with location denied, or with no usable fix, is
    /// still a perfectly valid session.
    var latitude: Double?
    var longitude: Double?

    var place: FocusPlace?

    /// The serialisable half of the `place` relationship. A SwiftData relation
    /// is an object pointer and won't survive being turned into JSON, so the
    /// explicit key is what a future sync payload carries.
    var placeID: UUID?

    // Sync-ready fields. Cheap now, a schema migration later.
    var remoteID: String?
    var updatedAt: Date
    var deletedAt: Date?

    init(start: Date, end: Date, coordinate: CLLocationCoordinate2D? = nil) {
        self.id = UUID()
        self.start = start
        self.end = end
        self.latitude = coordinate?.latitude
        self.longitude = coordinate?.longitude
        self.updatedAt = .now
    }

    var duration: TimeInterval {
        end.timeIntervalSince(start)
    }

    var coordinate: CLLocationCoordinate2D? {
        guard let latitude, let longitude else { return nil }
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    /// The only place a session is written. Everything that finishes a session
    /// routes through here, so when sync arrives this is the single spot that
    /// also has to enqueue an outbound change.
    @discardableResult
    static func record(
        start: Date,
        end: Date,
        coordinate: CLLocationCoordinate2D?,
        in context: ModelContext
    ) -> FocusSession {
        let session = FocusSession(start: start, end: end, coordinate: coordinate)
        context.insert(session)

        if let coordinate {
            let place = FocusPlace.findOrCreate(near: coordinate, in: context)

            place.absorb(coordinate)
            place.sessionCount += 1
            place.totalFocusSeconds += session.duration
            place.lastSessionAt = end
            place.updatedAt = .now

            session.place = place
            session.placeID = place.id
        }

        try? context.save()
        return session
    }
}
