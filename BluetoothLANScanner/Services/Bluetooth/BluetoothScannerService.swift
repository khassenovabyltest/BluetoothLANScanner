//
//  BluetoothScannerService.swift
//  BluetoothLANScanner
//
//  Created by Abylbek Khassenov on 04.12.2025.
//

import Foundation
import CoreBluetooth
import Combine

final class BluetoothScannerService: NSObject {
    
    // MARK: - Private Properties
    private var centralManager: CBCentralManager!
    private var discoveredDevices: [String: Device] = [:]
    private var scanContinuation: CheckedContinuation<[Device], Error>?
    private var scanTimer: Timer?
    
    private var isScanningInternal = false
    
    // MARK: - Public Properties
    
    var isScanning: Bool { isScanningInternal }
    
    // MARK: - Init
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
}

// MARK: - DeviceScanner

extension BluetoothScannerService: DeviceScanner {
    
    func startScanning(duration: TimeInterval) async throws -> [Device] {
        guard centralManager.state == .poweredOn else {
            throw NSError(domain: "Bluetooth not available", code: 0)
        }

        isScanningInternal = true
        discoveredDevices.removeAll()

        return try await withCheckedThrowingContinuation { continuation in
            self.scanContinuation = continuation
            centralManager.scanForPeripherals(withServices: nil, options: nil)

            scanTimer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { [weak self] _ in
                self?.stopScanning()
            }
        }
    }

    func stopScanning() {
        guard isScanningInternal else { return }

        centralManager.stopScan()
        scanTimer?.invalidate()
        scanTimer = nil
        isScanningInternal = false

        let devices = Array(discoveredDevices.values)
        scanContinuation?.resume(returning: devices)
        scanContinuation = nil
    }

}

// MARK: - CBCentralManagerDelegate

extension BluetoothScannerService: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {}

    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any],
                        rssi RSSI: NSNumber) {

        let uuid = peripheral.identifier.uuidString
        let name = peripheral.name ?? "Unknown"

        let device = Device(
            id: uuid,
            name: name,
            type: .bluetooth,
            rssi: RSSI.intValue,
            mac: nil,
            brand: nil,
            scannedAt: Date()
        )

        discoveredDevices[uuid] = device
    }
}
