//
//  DeviceRowView.swift
//  BluetoothLANScanner
//
//  Created by Abylbek Khassenov on 04.12.2025.
//

import SwiftUI

struct DeviceRowView: View {
    let device: Device

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(device.name.isEmpty ? "Unknown" : device.name)
                .font(.headline)

            Text(device.primaryIdentifier)
                .font(.subheadline)
                .foregroundColor(.secondary)

            if let rssi = device.rssi {
                Text("RSSI: \(rssi)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
