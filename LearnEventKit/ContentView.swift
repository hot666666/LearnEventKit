//
//  ContentView.swift
//  LearnEventKit
//
//  Created by hs on 7/28/24.
//

import SwiftUI

struct ContentView: View {
    @State var vm: ContentViewModel
    
    var body: some View {
        VStack{
            HStack {
                calendarsView
                Spacer()
                addButton
                    .disabled(!vm.calendarManager.isAuthorized)
            }
            .padding()
            .padding(.top, 20)
            
            eventsListView
        }
        .onAppear {
            vm.loadCalendars()
        }
        .onChange(of: vm.selectedCalendar) { _, newValue in
            vm.loadEvents(in: newValue)
        }
        .sheet(isPresented: $vm.isPresented) {
            EventView(vm: vm)
        }
    }
}
 
extension ContentView {
    var addButton: some View {
        Button(action: {
            vm.loadEventView()
        }, label: {
            Image(systemName: "plus")
        })
        .font(.largeTitle)
    }
    
    var calendarsView: some View {
        Picker("Select Calendar", selection: $vm.selectedCalendar) {
            ForEach(vm.calendars, id: \.self) { calendar in
                Text(calendar.title)
                    .tag(calendar)
            }
        }
        .pickerStyle(.menu)
    }
    
    @ViewBuilder
    var eventsListView: some View {
        if vm.events.isEmpty {
            Text("기간 내 이벤트가 존재하지 않습니다")
                .containerRelativeFrame(.vertical)
                .foregroundColor(.secondary)
        }
        List {
            ForEach(vm.events, id: \.self.id) { event in
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
                        vm.loadEventView(for: event)
                    }
            }
        }
    }
}

#Preview {
    ContentView(vm: .init(calendarManager: .init()))
}
