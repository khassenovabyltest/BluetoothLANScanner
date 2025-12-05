//
//  ScanSession.swift
//  BluetoothLANScanner
//
//  Created by Abylbek Khassenov on 04.12.2025.
//

import Foundation

public struct ScanSession: Identifiable, Hashable, Codable {
    // MARK: - Public
    
    public let id: UUID
    public let type: DeviceType
    public let startedAt: Date
    public let finishedAt: Date
    public let devices: [Device]
    
    public var duration: TimeInterval {
        finishedAt.timeIntervalSince(startedAt)
    }

    public var deviceCount: Int {
        devices.count
    }

    // MARK: - Init
    
    public init(
        id: UUID = UUID(),
        type: DeviceType,
        startedAt: Date,
        finishedAt: Date,
        devices: [Device]
    ) {
        self.id = id
        self.type = type
        self.startedAt = startedAt
        self.finishedAt = finishedAt
        self.devices = devices
    }
}
