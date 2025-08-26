//
//  MapViewModel.swift
//  BarFriendFinder
//
//  Created by Mikhail Khinevich on 13.10.23.
//

import Foundation
import MapKit
import SwiftUI
import OSLog

@Observable class MapViewModel {
    var cameraPosition: MapCameraPosition = .region(.userRegion)
    var searchText = ""
    var showSearch = false
    var results: [MKMapItem] = []
    var showDetails = false
    var logger = Logger()

    func searchPlaces() async {
        logger.info("Searching places")
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        request.region = .userRegion
        let results = try? await MKLocalSearch(request: request).start()
        self.results = results?.mapItems ?? []
    }
}
