//
//  BluetoothScanViewModel.swift
//  BluetoothLANScanner
//
//  Created by Abylbek Khassenov on 04.12.2025.
//

import Foundation
import Combine

@MainActor
final class BluetoothScanViewModel: ObservableObject {
    @Published var devices: [Device] = []
    @Published var isScanning = false
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let scanner: DeviceScanner
    private let history: HistoryRepository

    init(scanner: DeviceScanner, history: HistoryRepository) {
        self.scanner = scanner
        self.history = history
    }

    func startScan(duration: TimeInterval = 15) {
        guard !isScanning else { return }

        let startedAt = Date()

        isScanning = true
        isLoading = true
        errorMessage = nil
        devices = []

        Task {
            do {
                let scanned = try await scanner.startScanning(duration: duration)
                let finishedAt = Date()

                let session = ScanSession(
                    type: .bluetooth,
                    startedAt: startedAt,
                    finishedAt: finishedAt,
                    devices: scanned
                )

                do {
                    try history.saveSession(session)
                    print("✅ Saved session \(session.id) devices: \(session.devices.count)")
                } catch {
                    errorMessage = "Скан выполнен, но не удалось сохранить: \(error.localizedDescription)"
                }

                devices = scanned.sorted { ($0.rssi ?? -100) > ($1.rssi ?? -100) }
            } catch {
                errorMessage = error.localizedDescription
            }

            isScanning = false
            isLoading = false
        }
    }

    func stopScan() {
        scanner.stopScanning()
        isScanning = false
        isLoading = false
    }
}
