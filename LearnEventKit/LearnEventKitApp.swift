//
//  LearnEventKitApp.swift
//  LearnEventKit
//
//  Created by hs on 7/28/24.
//

import SwiftUI

@main
struct LearnEventKitApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var calendarManager = CalendarManager()
    
    var body: some Scene {
        WindowGroup {
            Group {
                if calendarManager.isAuthorized {
                    ContentView(vm: .init(calendarManager: calendarManager))
                        .environmentObject(calendarManager)
                } else {
                    Text("NEED AUTHORIZATION")
                }
            }
            .onAppear {
                calendarManager.checkAuthorization()
            }
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .active {
                    calendarManager.checkAuthorization()
                }
            }
        }
    }
}
