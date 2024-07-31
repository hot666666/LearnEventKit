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
    
    func fetchEvents(startDate: Date, endDate: Date, calendars: [EKCalendar]? = nil) -> [EKEvent] {
        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: calendars)
        return eventStore.events(matching: predicate)
    }
    
    func addEvent(title: String, startDate: Date, endDate: Date, calendar: EKCalendar?=nil) throws {
        let event = EKEvent(eventStore: eventStore)
        
        event.title = title
        event.startDate = startDate
        event.endDate = endDate
        event.calendar = calendar ?? eventStore.defaultCalendarForNewEvents

        do {
            try eventStore.save(event, span: .thisEvent)
        } catch {
            throw error
        }
    }
    
    // TODO: - update calendar
    func updateEvent(_ event: EKEvent, title: String, startDate: Date, endDate: Date, isAllDay: Bool) throws {
        event.title = title
        event.isAllDay = isAllDay
        event.startDate = isAllDay ? startDate.startOfDay : startDate
        event.endDate = isAllDay ? endDate.endOfDay : endDate

        do {
            try eventStore.save(event, span: .thisEvent)
        } catch {
            throw error
        }
    }
    
    func removeEvents(_ events: [EKEvent]) throws {
        do {
            try events.forEach { event in
                try _removeEvent(event)
            }
            try eventStore.commit()
        } catch {
            eventStore.reset()
            throw error
        }
    }
    
    func removeEvent(_ event: EKEvent) throws {
        try eventStore.remove(event, span: .thisEvent, commit: true)
    }
    
    private func _removeEvent(_ event: EKEvent) throws {
        try eventStore.remove(event, span: .thisEvent, commit: false)
    }
}
