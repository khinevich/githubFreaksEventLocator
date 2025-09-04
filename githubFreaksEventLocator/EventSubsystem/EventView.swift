//
//  EventView.swift
//  GithubFreaksEventLocatorApp
//
//  Created by Mikhail Khinevich on 11.10.23.
//

import SwiftUI 
import OSLog

struct EventView: View {
    @State var viewModel = EventViewModel()
    @State private var isPresented = false
    @Bindable var viewModelPlace: PlaceViewModel

    var logger = Logger()

    var body: some View {
        VStack {
            Form {
                Section("Choose a date & time") {
                    DatePicker("Date: ", selection: $viewModel.currentTime, in: Date()...)
                }
                Section("Detailed Information") {
                    TextField("Description",
                              text: $viewModel.description,
                              axis: .vertical).frame(height: 60)
                }
                Button("Add Event", action: {
                    logger.info("Updating Event List")
                })
            }
            .frame(width: 370)
            .cornerRadius(20)
        }
    }
}

#Preview {
    EventView(viewModelPlace: PlaceViewModel())
}
