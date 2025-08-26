//
//  EventViewModel.swift
//  BarFriendFinder
//
//  Created by Mikhail Khinevich on 12.10.23.
//

import Foundation
import OSLog
import MapKit
@Observable class EventViewModel {
    var currentTime = Date()
    var description = ""
    var event = EventModel()
    let logger = Logger()
    var events: [EventModel] = []

    func formateDate() -> String {
        logger.info("Formating Date to String")
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy (HH:mm)"
        return dateFormatter.string(from: currentDate)
    }

    func updateEventList(_ place: MKMapItem) {
        let dataString = formateDate()
        event.date = dataString
        event.description = description
        event.place = place
        events.append(event)
        logger.info("Adding Event to Event List")
    }
}
