//
//  LocationService.swift
//  anchor
//

import CoreLocation
import Observation
import SwiftUI

@Observable
@MainActor
final class LocationService: NSObject, CLLocationManagerDelegate {

    private let manager = CLLocationManager()

    private(set) var authorization: CLAuthorizationStatus

    private(set) var lastError: String?

    @ObservationIgnored
    private var fixContinuation: CheckedContinuation<CLLocationCoordinate2D?, Never>?

    @ObservationIgnored
    private var authorizationContinuation: CheckedContinuation<Void, Never>?

    override init() {
        authorization = manager.authorizationStatus
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    var canReadLocation: Bool {
        authorization == .authorizedWhenInUse || authorization == .authorizedAlways
    }

    var isDenied: Bool {
        authorization == .denied || authorization == .restricted
    }

    func requestWhenInUseIfNeeded() async {
        guard authorization == .notDetermined else { return }

        await withCheckedContinuation { continuation in
            authorizationContinuation = continuation
            manager.requestWhenInUseAuthorization()
        }
    }

    func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
    
    func currentFix() async -> CLLocationCoordinate2D? {
        guard canReadLocation else { return nil }
        // A second caller while one is in flight would clobber the continuation.
        guard fixContinuation == nil else { return nil }

        return await withCheckedContinuation { continuation in
            fixContinuation = continuation
            manager.requestLocation()

            Task {
                try? await Task.sleep(for: .seconds(8))
                resumeFix(with: nil)
            }
        }
    }


    private func resumeFix(with coordinate: CLLocationCoordinate2D?) {
        guard let continuation = fixContinuation else { return }
        fixContinuation = nil
        continuation.resume(returning: coordinate)
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        MainActor.assumeIsolated {
            authorization = manager.authorizationStatus
            if canReadLocation { lastError = nil }

            if let authorizationContinuation {
                self.authorizationContinuation = nil
                authorizationContinuation.resume()
            }
        }
    }

    nonisolated func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        MainActor.assumeIsolated {
            resumeFix(with: locations.last?.coordinate)
        }
    }

    nonisolated func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        MainActor.assumeIsolated {
            lastError = error.localizedDescription
            resumeFix(with: nil)
        }
    }
}
