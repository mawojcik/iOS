//
//  zadanie3App.swift
//  zadanie3
//
//  Created by Maciej Wójcik on 08/12/2025.
//

import SwiftUI

@main
struct zadanie3App: App {
    let persistenceController = PersistenceController.shared
    
    @StateObject var cartManager = CartManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(cartManager)
        }
    }
}
