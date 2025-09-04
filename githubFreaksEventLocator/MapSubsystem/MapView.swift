//
//  MapView.swift
//  GithubFreaksEventLocatorApp
//
//  Created by Mikhail Khinevich on 11.10.23.
//

import SwiftUI
import MapKit
struct MapView: View {
    @State private var viewModel = MapViewModel()
    @State private var viewModelPlace = PlaceViewModel()

    var body: some View {
        NavigationStack {
            Map(position: $viewModel.cameraPosition, selection: $viewModelPlace.mapSelection) {
                Annotation("My location", coordinate: .userLocation) {
                    userLocationView
                }
                // Displays all the marks that corresponds to search
                ForEach(viewModel.results, id: \.self) { item in
                    let placemark = item.placemark
                    Marker(placemark.name ?? "", coordinate: placemark.coordinate)
                }
            }
            .mapControls {
                // 3D, compass, currentLocation
                // (if you push last button, it will show San-Francisco,
                // CA location, idk, it simulator iPhone location
                MapCompass()
                MapPitchToggle()
                MapUserLocationButton()
            }
            .navigationTitle("Map")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $viewModel.searchText, isPresented: $viewModel.showSearch)
            .toolbarBackground(.visible, for: .navigationBar)
            .onSubmit(of: .search) {
                Task { await viewModel.searchPlaces( )
                }
            }
            .onChange(of: viewModelPlace.mapSelection, { _, newValue in
                viewModel.showDetails = newValue != nil
            })
            .sheet(isPresented: $viewModel.showDetails, content: {
                PlaceView(viewModel: viewModelPlace)
                    .presentationDetents([.height(400)])
                    .presentationBackgroundInteraction(.enabled(upThrough: .height(400)))
                    .presentationCornerRadius(12)
            })
        }
    }
    var userLocationView: some View {
        // mark of userLocation
        ZStack {
            Circle().frame(width: 32, height: 32).foregroundColor(.blue.opacity(0.25))
            Circle().frame(width: 20, height: 22).foregroundColor(.white)
            Circle().frame(width: 12, height: 12).foregroundColor(.blue)
        }
    }
}

extension CLLocationCoordinate2D {
    static var userLocation: CLLocationCoordinate2D {
        return .init(latitude: 48.137154, longitude: 11.576124)
    }
}

extension MKCoordinateRegion {
    // Extenstion to MapKit, user Region (around Marienplatz)
    static var userRegion: MKCoordinateRegion {
        return .init(center: .userLocation,
                     latitudinalMeters: 1000,
                     longitudinalMeters: 1000)
    }
}
#Preview {
    MapView()
}
