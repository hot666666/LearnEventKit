//
//  CalendarManager.swift
//  LearnEventKit
//
//  Created by hs on 7/28/24.
//

import EventKit
import SwiftUI

class CalendarManager: ObservableObject {
    private var eventStore: EKEventStore
    
    @Published var isAuthorized: Bool = false
    
    init() {
        self.eventStore = EKEventStore()
    }
}

extension CalendarManager {
    func checkAuthorization() {
        var _isAuthorized = false
        
        if #available(iOS 17.0, *) {
            _isAuthorized = EKEventStore.authorizationStatus(for: .event) == .fullAccess
        } else {
            _isAuthorized = EKEventStore.authorizationStatus(for: .event) == .authorized
        }
        
        isAuthorized = _isAuthorized
        if !_isAuthorized {
            Task {
                try? await requestAuthorization()
            }
        }
    }
    
    func requestAuthorization() async throws -> Bool {
        if #available(iOS 17.0, *) {
            return try await eventStore.requestFullAccessToEvents()
        } else {
            return try await eventStore.requestAccess(to: .event)
        }
    }
    
    func listenForEventStoreChanges() async {
        /// 다음과 같이 NotificaitonCenter를 이용하면, .EKEventStoreCahnged를 통해 업데이트 시 특정 동작을 수행시킬 수 있다
        let center = NotificationCenter.default
        let notifications = center.notifications(named: .EKEventStoreChanged)
            .map { (notification: Notification) in
                notification.name
            }
        
        for await _ in notifications {
            // TODO: - 업데이트
        }
    }
}

extension CalendarManager {
    func fetchCalendars() -> [EKCalendar] {
        eventStore.calendars(for: .event)
    }
    
    func fetchEvents(startDate: Date, endDate: Date, calendars: [EKCalendar]? = nil) -> [EventModel] {
        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: calendars)
        let events = eventStore.events(matching: predicate)
        return events.map { EventModel(event: $0) }
    }
    
    func addEvent(event: EventModel, calendar: EKCalendar? = nil) throws -> EventModel {
        let ekEvent = EKEvent(eventStore: eventStore)
        
        ekEvent.title = event.title
        ekEvent.isAllDay = event.isAllDay
        ekEvent.startDate = event.isAllDay ? event.startDate.startOfDay : event.startDate
        ekEvent.endDate = event.isAllDay ? event.startDate.endOfDay : event.endDate
        ekEvent.calendar = calendar ?? eventStore.defaultCalendarForNewEvents
        try eventStore.save(ekEvent, span: .thisEvent)
        
        if ekEvent.isAllDay {
            event.endDate = ekEvent.endDate
        }
        
        event.id = ekEvent.eventIdentifier
        return event
    }
    
    // TODO: - update calendar
    func updateEvent(_ eventModel: EventModel) throws {
        guard let ekEvent = eventStore.event(withIdentifier: eventModel.id) else { return }
        ekEvent.title = eventModel.title
        ekEvent.startDate = eventModel.startDate
        ekEvent.isAllDay = eventModel.isAllDay
        if ekEvent.isAllDay {
            ekEvent.endDate = eventModel.startDate.endOfDay
        } else {
            ekEvent.endDate = eventModel.endDate
        }
        try eventStore.save(ekEvent, span: .thisEvent)
    }
    
    func removeEvent(_ eventModel: EventModel) throws {
        guard let ekEvent = eventStore.event(withIdentifier: eventModel.id) else { return }
        try eventStore.remove(ekEvent, span: .thisEvent)
    }
}
