//
//  BluetoothLANScannerApp.swift
//  BluetoothLANScanner
//
//  Created by Abylbek Khassenov on 04.12.2025.
//

import SwiftUI

@main
struct BluetoothLANScannerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
