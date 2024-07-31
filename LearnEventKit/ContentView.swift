//
//  ContentView.swift
//  LearnEventKit
//
//  Created by hs on 7/28/24.
//

import SwiftUI
import EventKit

struct ContentView: View {
    @EnvironmentObject private var calendarManager: CalendarManager
    
    @State private var calendars: [EKCalendar] = []
    @State private var events: [EKEvent] = []
    @State private var selectedCalendar: EKCalendar?
    @State private var selectedEvent: EKEvent?
    @State private var isPresented = false
    
    var body: some View {
        VStack{
            HStack {
                calendarsView
                Spacer()
                addButton
                    .disabled(!calendarManager.isAuthorized)
            }
            .padding()
            
            eventsView
        }
        .onAppear {
            calendars = calendarManager.fetchCalendars()
            selectedCalendar = calendars.first(where: { $0.title == "캘린더"})
        }
        .onChange(of: selectedCalendar) { _, newValue in
            if let calendar = newValue {
                events = calendarManager.fetchEvents(startDate: .now, endDate: .now.adding(months: 1), calendars: [calendar])
            }
        }
        .sheet(isPresented: $isPresented) {
            EventView(event: selectedEvent)
        }
    }
    
    var addButton: some View {
        Button(action: {
            selectedEvent = nil
            isPresented = true
        }, label: {
            Image(systemName: "plus")
        })
        .font(.largeTitle)
    }
    
    var calendarsView: some View {
        Picker("Select Calendar", selection: $selectedCalendar) {
            ForEach(calendars, id: \.self) { calendar in
                Text(calendar.title)
                    .tag(calendar as EKCalendar?)
            }
        }
        .pickerStyle(.menu)
    }
    
    var eventsView: some View {
        List {
            ForEach(events, id: \.self.eventIdentifier) { event in
                VStack(alignment: .leading) {
                    Text(event.title)
                        .font(.title3)
                    HStack {
                        if event.startDate.isSameDay(as: event.endDate) {
                            Text(event.startDate.toString())
                        } else {
                            Text("\(event.startDate.toString()) - \(event.endDate.toString())")
                        }
                    }
                    .font(.subheadline)
                }
                    .onTapGesture {
                        selectedEvent = event
                        isPresented = true
                    }
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(CalendarManager())
}
