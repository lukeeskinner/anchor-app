//
//  PlaceLookup.swift
//  anchor
//

import CoreLocation
import MapKit

/// Turns a coordinate into a place name and, where possible, a category.
///
/// This is the only part of anchor that touches the network.
enum PlaceLookup {

    struct Found {
        let name: String
        let category: MKPointOfInterestCategory?
    }

    /// The categories anchor treats as somewhere you'd deliberately go to work.
    /// Kept in one place so widening it later is a one-line change.
    static let studyCategories: [MKPointOfInterestCategory] = [.library, .cafe]

    static func isStudySpot(_ category: MKPointOfInterestCategory?) -> Bool {
        guard let category else { return false }
        return studyCategories.contains(category)
    }

    /// Best effort, in descending order of usefulness: a nearby study POI, then
    /// any nearby POI for its name, then a street address. A nil result is a
    /// normal outcome — offline, or genuinely nowhere — and callers must treat
    /// it as such rather than as a failure.
    static func lookup(_ coordinate: CLLocationCoordinate2D) async -> Found? {
        if let found = await search(
            coordinate,
            filter: MKPointOfInterestFilter(including: studyCategories)
        ) {
            return found
        }

        if let found = await search(coordinate, filter: nil) {
            return found
        }

        return await reverseGeocode(coordinate)
    }

    // MARK: - Steps

    private static func search(
        _ coordinate: CLLocationCoordinate2D,
        filter: MKPointOfInterestFilter?
    ) async -> Found? {
        let request = MKLocalPointsOfInterestRequest(center: coordinate, radius: 75)
        request.pointOfInterestFilter = filter

        guard let response = try? await MKLocalSearch(request: request).start() else {
            return nil
        }

        let target = CLLocation(
            latitude: coordinate.latitude,
            longitude: coordinate.longitude
        )

        let nearest = response.mapItems
            .map { ($0, $0.location.distance(from: target)) }
            .min { $0.1 < $1.1 }?
            .0

        guard let nearest, let name = nearest.name else { return nil }
        return Found(name: name, category: nearest.pointOfInterestCategory)
    }

    private static func reverseGeocode(
        _ coordinate: CLLocationCoordinate2D
    ) async -> Found? {
        let location = CLLocation(
            latitude: coordinate.latitude,
            longitude: coordinate.longitude
        )

        guard
            let request = MKReverseGeocodingRequest(location: location),
            let items = try? await request.mapItems,
            let item = items.first,
            let name = item.name
        else {
            return nil
        }

        return Found(name: name, category: item.pointOfInterestCategory)
    }
}
