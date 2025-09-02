//
//  PlaceViewModel.swift
//  GithubFreaksEventLocatorApp
//
//  Created by Mikhail Khinevich on 13.10.23.
//

import Foundation
import SwiftUI
import MapKit
import OSLog

@Observable class PlaceViewModel {
    var placeModel: PlaceModel?
    var showPlaceView = false
    var mapSelection: MKMapItem?
    var lookAroundScene: MKLookAroundScene?

    let logger = Logger()

    // this func enables 3D view
    func fetchLookAroundPreview() {
        logger.info("Fetching Look around preview.")
        if let mapSelection {
            lookAroundScene = nil
            Task {
                let request = MKLookAroundSceneRequest(mapItem: mapSelection)
                lookAroundScene = try? await request.scene
            }
        }
    }

    func openInMaps() {
        mapSelection?.openInMaps()
    }
}
