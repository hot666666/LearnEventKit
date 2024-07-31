//
//  EventView.swift
//  LearnEventKit
//
//  Created by hs on 7/31/24.
//

import SwiftUI
import EventKit

struct EventView: View {
    @EnvironmentObject private var calendarManager: CalendarManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var title: String = ""
    @State private var isAllDay: Bool = false
    @State private var startDate: Date = .now
    @State private var endDate: Date = .now.adding(days: 1)
    
    var event: EKEvent?
    
    init(event: EKEvent?) {
        self.event = event
        
        if let event = event {
            _title = State(initialValue: event.title)
            _isAllDay = State(initialValue: event.isAllDay)
            _startDate = State(initialValue: event.startDate)
            _endDate = State(initialValue: event.endDate)
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("이벤트 정보")) {
                    TextField("제목", text: $title)
                    Toggle("종일", isOn: $isAllDay)
                    
                    if isAllDay {
                        DatePicker("날짜", selection: $startDate, displayedComponents: .date)
                    } else {
                        DatePicker("시작 시간", selection: $startDate)
                        DatePicker("종료 시간", selection: $endDate)
                    }
                }
            }
            .safeAreaInset(edge: .bottom){
                removeButton
                    .opacity(event == nil ? 0 : 1)
            }
            .navigationTitle(event == nil ? "이벤트 생성" : "이벤트 수정")
            .navigationBarItems(
                leading: Button("취소") {
                    dismiss()
                },
                trailing: Button("저장") {
                    saveEvent()
                }
            )
        }
    }
    
    var removeButton: some View {
        Button(action: {
            try? calendarManager.removeEvent(event!)
            dismiss()
        }, label: {
            Image(systemName: "trash.fill")
        })
        .font(.title)
        .padding()
    }
    
    private func saveEvent() {
        do {
            if let existingEvent = event {
                try calendarManager.updateEvent(existingEvent, title: title, startDate: startDate, endDate: isAllDay ? startDate.endOfDay : endDate, isAllDay: isAllDay)
            } else {
                try calendarManager.addEvent(title: title, startDate: startDate, endDate: isAllDay ? startDate.endOfDay : endDate)
            }
            dismiss()
        } catch {
            print("Error saving event: \(error.localizedDescription)")
        }
    }
}
