//
//  CalendarApp.swift
//  Calendar
//
//  Created by 江越瑠一 on 2022/07/13.
//

import SwiftUI

@main
struct CalendarApp: App {
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}


