//
//  ContentViewModel.swift
//  LearnEventKit
//
//  Created by hs on 7/31/24.
//

import EventKit
import Observation

@Observable
class ContentViewModel {
    var calendarManager: CalendarManager
    var calendars: [EKCalendar] = []
    var selectedCalendar: EKCalendar?
    var events: [EventModel] = []
    var selectedEvent: EventModel?
    var isPresented = false
    
    init(calendarManager: CalendarManager) {
        self.calendarManager = calendarManager
    }
    
    var isCreateMode: Bool {
        selectedEvent == nil
    }
    
    func loadCalendars() {
        calendars = calendarManager.fetchCalendars()
        selectedCalendar = calendars.first(where: { $0.title == "캘린더" })
    }
    
    func loadEvents(in newValue: EKCalendar?) {
        if let calendar = newValue {
            events = calendarManager.fetchEvents(startDate: .now, endDate: .now.adding(months: 1), calendars: [calendar])
        }
    }
    
    func loadEventView(for event: EventModel? = nil) {
        selectedEvent = event
        isPresented = true
    }
    
    func saveEvent(event: EventModel) {
        do {
            if isCreateMode {
                let newEvent = try calendarManager.addEvent(event: event, calendar: selectedCalendar)
                events.append(newEvent)
            } else {
                try calendarManager.updateEvent(event)
                selectedEvent?.update(with: event)
            }
        } catch {
            print("Error saving event: \(error.localizedDescription)")
        }
    }
    
    func removeEvent() {
        do {
            guard let selectedEvent = selectedEvent else { return }
            try calendarManager.removeEvent(selectedEvent)
            events.removeAll(where: { $0.id == selectedEvent.id })
        } catch {
            print("Error removing event: \(error.localizedDescription)")
        }
    }
}
