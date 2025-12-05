//
//  DeviceScanner.swift
//  BluetoothLANScanner
//
//  Created by Abylbek Khassenov on 04.12.2025.
//

import Foundation
import Combine

protocol DeviceScanner {
    var isScanning: Bool { get }
    func startScanning(duration: TimeInterval) async throws -> [Device]
    func stopScanning()
}
