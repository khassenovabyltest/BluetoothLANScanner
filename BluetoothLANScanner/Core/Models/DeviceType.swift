//
//  DeviceType.swift
//  BluetoothLANScanner
//
//  Created by Abylbek Khassenov on 04.12.2025.
//

import Foundation

public enum DeviceType: String, Codable {
    case bluetooth
    case lan
}

public struct Device: Identifiable, Hashable, Codable {
    
    // MARK: - Public
    
    public let id: String
    public let name: String
    public let type: DeviceType
    public let rssi: Int?

    public let mac: String?
    public let brand: String?

    public let scannedAt: Date
    
    public var primaryIdentifier: String {
        id
    }
    
    // MARK: - Init

    public init(
        id: String,
        name: String,
        type: DeviceType,
        rssi: Int? = nil,
        mac: String? = nil,
        brand: String? = nil,
        scannedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.rssi = rssi
        self.mac = mac
        self.brand = brand
        self.scannedAt = scannedAt
    }
}
