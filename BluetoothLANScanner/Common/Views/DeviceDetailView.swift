//
//  DeviceDetailView.swift
//  BluetoothLANScanner
//
//  Created by Abylbek Khassenov on 04.12.2025.
//

import SwiftUI

struct DeviceDetailView: View {
    let device: Device

    var body: some View {
        ZStack {
            AppBackgroundView()
                .ignoresSafeArea()

            List {
                Section("Основное") {
                    row("Имя", device.name.isEmpty ? "Unknown" : device.name)
                    row("Тип", device.type.rawValue)
                    row("ID / IP", device.primaryIdentifier)
                }

                if let mac = device.mac, !mac.isEmpty {
                    row("MAC", mac)
                }
                if let brand = device.brand, !brand.isEmpty {
                    row("Brand", brand)
                }
                if let rssi = device.rssi {
                    row("RSSI", "\(rssi)")
                }

                row("Время", device.scannedAt.formatted(date: .abbreviated, time: .standard))
            }
            .scrollContentBackground(.hidden)
            .listStyle(.insetGrouped)
        }
        .navigationTitle(device.name.isEmpty ? "Детали" : device.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    private func row(_ title: String, _ value: String) -> some View {
        HStack(spacing: 12) {
            Text(title)
                .foregroundStyle(.primary)
            Spacer(minLength: 12)
            Text(value)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.trailing)
        }
        .listRowBackground(Color.clear)
    }
}
