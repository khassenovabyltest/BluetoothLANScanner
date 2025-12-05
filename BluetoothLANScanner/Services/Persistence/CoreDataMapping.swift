//
//  CoreDataMapping.swift
//  BluetoothLANScanner
//
//  Created by Abylbek Khassenov on 05.12.2025.
//

import Foundation

extension CDScanSession {
    func toDomain() -> ScanSession {
        let devicesSet = (devices as? Set<CDDevice>) ?? []
        let domainDevices = devicesSet.map { $0.toDomain() }

        return ScanSession(
            id: id ?? UUID(),
            type: DeviceType(rawValue: type ?? "") ?? .lan,
            startedAt: startedAt ?? Date(),
            finishedAt: finishedAt ?? (startedAt ?? Date()),
            devices: domainDevices
        )
    }
}

extension CDDevice {
    func toDomain() -> Device {
        return Device(
            id: id ?? "UNKNOWN",
            name: name ?? "Unknown",
            type: DeviceType(rawValue: type ?? "") ?? .lan,
            rssi: Int(rssi),
            mac: mac,
            brand: brand,
            scannedAt: scannedAt ?? Date()
        )
    }
}

