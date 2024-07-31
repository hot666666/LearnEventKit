//
//  EventModel.swift
//  LearnEventKit
//
//  Created by hs on 7/31/24.
//

import Foundation
import EventKit

@Observable
class EventModel {
    var id: String = UUID().uuidString
    var title: String = "제목없음"
    var isAllDay: Bool = true
    var startDate: Date = .now.startOfDay
    var endDate: Date = .now.endOfDay
    
    init() {}
    
    init(event: EKEvent) {
        self.id = event.eventIdentifier
        self.title = event.title
        self.isAllDay = event.isAllDay
        self.startDate = event.startDate
        self.endDate = event.endDate
    }
    
    init(event: EventModel) {
        self.id = event.id
        self.title = event.title
        self.isAllDay = event.isAllDay
        self.startDate = event.startDate
        self.endDate = event.endDate
    }
    
    func update(with event: EventModel) {
        self.title = event.title
        self.isAllDay = event.isAllDay
        self.startDate = event.startDate
        if self.isAllDay {
            self.endDate = event.startDate.endOfDay
        } else {
            self.endDate = event.endDate
        }
    }
}
