//
//  EventView.swift
//  LearnEventKit
//
//  Created by hs on 7/31/24.
//

import SwiftUI

struct EventView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isAlert = false
    
    private var vm: ContentViewModel
    private var event: EventModel
    
    init(vm: ContentViewModel) {
        self.vm = vm
        if self.vm.isCreateMode {
            event = EventModel()
        } else {
            event = EventModel(event: self.vm.selectedEvent!)
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("이벤트 정보")) {
                    TextField("제목", text: Bindable(event).title)
                    Toggle("종일", isOn: Bindable(event).isAllDay)
                    
                    if event.isAllDay {
                        DatePicker("날짜", selection: Bindable(event).startDate, displayedComponents: .date)
                    } else {
                        DatePicker("시작 시간", selection: Bindable(event).startDate)
                        DatePicker("종료 시간", selection: Bindable(event).endDate, in: event.startDate...)
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                removeButton
                    .opacity(vm.isCreateMode ? 0 : 1)
            }
            .navigationTitle(vm.isCreateMode ? "이벤트 생성" : "이벤트 수정")
            .navigationBarItems(
                leading: Button("취소") {
                    dismiss()
                },
                trailing: Button("저장") {
                    vm.saveEvent(event: event)
                    dismiss()
                }
                .disabled(event.title.isEmpty)
            )
        }
        .alert("삭제",
               isPresented: $isAlert,
               actions: { alertButtons },
               message: { Text("삭제하시겠습니까?") })
    }
}

extension EventView {
    var removeButton: some View {
        Button(action: {
            isAlert = true
        }, label: {
            Image(systemName: "trash.fill")
        })
        .font(.title)
        .padding()
    }
    
    @ViewBuilder
    var alertButtons: some View {
        Button("확인") {
            vm.removeEvent()
            dismiss()
        }
        Button("취소") {
            isAlert = false
        }
    }

}
