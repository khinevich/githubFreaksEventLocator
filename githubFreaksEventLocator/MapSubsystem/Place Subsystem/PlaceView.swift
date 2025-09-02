//
//  MarkView.swift
//  GithubFreaksEventLocatorApp
//
//  Created by Mikhail Khinevich on 13.10.23.
//

import SwiftUI
import MapKit
import OSLog

struct PlaceView: View {
    @Bindable var viewModel: PlaceViewModel
    var logger = Logger()

    var body: some View {
        NavigationView {
            VStack {
                placeDetailView
                    .padding(.horizontal)
                    .padding(.top)
                if let scene = viewModel.lookAroundScene {
                    // MapKit views
                    LookAroundPreview(initialScene: scene)
                        .frame(height: 200)
                        .cornerRadius(12)
                        .padding()
                } else {
                    // MapKit views
                    ContentUnavailableView("No preview available", systemImage: "eye.slash")
                }
                HStack(spacing: 18) {
                    Button {
                        if let mapSelect = viewModel.mapSelection {
                            mapSelect.openInMaps()
                        }
                        logger.info("Opening in Maps")
                    } label: {
                        Text("Open in maps")
                            .modifier(PlaceViewModifier(color: .green))
                    }
                    NavigationLink(destination: EventView(viewModelPlace: viewModel), label: {
                        Text("Add Event")
                            .modifier(PlaceViewModifier(color: .blue))
                    })
                }
            }
        }
        .onAppear {
            viewModel.fetchLookAroundPreview()
        }
        // when user choose another mark
        .onChange(of: viewModel.mapSelection) { _, _ in
            viewModel.fetchLookAroundPreview()
        }
        .padding()
    }

    var placeDetailView: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(viewModel.mapSelection?.placemark.name ?? "")
                    .font(.title2)
                    .fontWeight(.semibold)
                Text(viewModel.mapSelection?.placemark.title ?? "")
                    .font(.footnote)
                    .foregroundStyle(.gray)
                    .lineLimit(2)
                    .padding(.trailing)
            }
            Spacer()
            Button {
                viewModel.showPlaceView.toggle()
                viewModel.mapSelection = nil
                logger.info("Showing PlaceView")
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundStyle(.gray, Color(.systemGray6))
            }
        }
    }
}
#Preview {
    PlaceView(viewModel: PlaceViewModel())
}
