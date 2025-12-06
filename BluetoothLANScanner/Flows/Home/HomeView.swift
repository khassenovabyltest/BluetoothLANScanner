//
//  HomeView.swift
//  BluetoothLANScanner
//
//  Created by Abylbek Khassenov on 04.12.2025.
//

import SwiftUI

struct HomeView: View {

    private enum Tab: Hashable {
        case bluetooth
        case lan
        case history
    }

    @State private var selectedTab: Tab = .bluetooth

    var body: some View {
        TabView(selection: $selectedTab) {

            NavigationStack {
                BluetoothScanView()
            }
            .tabItem {
                Label("Bluetooth", systemImage: "antenna.radiowaves.left.and.right")
            }
            .tag(Tab.bluetooth)

            NavigationStack {
                LanScanView()
            }
            .tabItem {
                Label("LAN", systemImage: "wifi")
            }
            .tag(Tab.lan)

            NavigationStack {
                HistoryView()
            }
            .tabItem {
                Label("История", systemImage: "clock.arrow.circlepath")
            }
            .tag(Tab.history)
        }
        .tint(.white)
    }
}
