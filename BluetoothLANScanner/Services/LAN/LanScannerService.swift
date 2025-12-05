//
//  LanScannerService.swift
//  BluetoothLANScanner
//
//  Created by Abylbek Khassenov on 04.12.2025.
//

import Foundation
import LanScanner
import Network

final class LanScannerService: NSObject {
    
    // MARK: - Private Properties
    
    private var scanner: LanScanner?
    private var discoveredDevices: [Device] = []
    private var continuation: CheckedContinuation<[Device], Error>?
    private var isScanningInternal = false
    
    // MARK: - Public Properties
    
    var onProgress: ((Double, String) -> Void)?
    var isScanning: Bool { isScanningInternal }
}

// MARK: - DeviceScanner

extension LanScannerService: DeviceScanner {
    func startScanning(duration: TimeInterval) async throws -> [Device] {
        guard !isScanning else {
            throw NSError(domain: "Already scanning", code: 1)
        }

        discoveredDevices = []
        isScanningInternal = true

        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation

            scanner = LanScanner(delegate: self)

            Task {
                let ok = await canReachRouter("192.168.1.1")
                print("LAN reachability router 192.168.1.1:", ok)
            }

            scanner?.start()

            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                self.stopScanning()
            }
        }
    }

    func stopScanning() {
        scanner?.stop()
        scanner = nil
        isScanningInternal = false

        continuation?.resume(returning: discoveredDevices)
        continuation = nil
    }

}

// MARK: - LanScannerDelegate

extension LanScannerService: LanScannerDelegate {
    func lanScanHasUpdatedProgress(_ progress: CGFloat, address: String) {
        onProgress?(Double(progress), address)
    }

    func lanScanDidFindNewDevice(_ device: LanDevice) {
        let ip = device.ipAddress.isEmpty ? "0.0.0.0" : device.ipAddress

        let newDevice = Device(
            id: ip,
            name: device.name.isEmpty ? "Unknown" : device.name,
            type: .lan,
            rssi: nil,
            mac: device.mac.isEmpty ? nil : device.mac,
            brand: device.brand.isEmpty ? nil : device.brand,
            scannedAt: Date()
        )

        if !discoveredDevices.contains(where: { $0.id == newDevice.id }) {
            discoveredDevices.append(newDevice)
        }
    }

    func lanScanDidFinishScanning() {
        stopScanning()
    }

    private func canReachRouter(_ ip: String) async -> Bool {
        await withCheckedContinuation { cont in
            let conn = NWConnection(host: NWEndpoint.Host(ip), port: 80, using: .tcp)

            var didResume = false
            func finish(_ value: Bool) {
                guard !didResume else { return }
                didResume = true
                conn.stateUpdateHandler = nil
                conn.cancel()
                cont.resume(returning: value)
            }

            conn.stateUpdateHandler = { state in
                switch state {
                case .ready:
                    finish(true)
                case .failed(_), .cancelled:
                    finish(false)
                default:
                    break
                }
            }

            conn.start(queue: .global())

            DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
                finish(false)
            }
        }
    }
}
