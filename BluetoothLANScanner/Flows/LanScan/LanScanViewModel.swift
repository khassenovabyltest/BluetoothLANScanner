//
//  LanScanViewModel.swift
//  BluetoothLANScanner
//
//  Created by Abylbek Khassenov on 04.12.2025.
//

import Foundation
import Combine

@MainActor
final class LanScanViewModel: ObservableObject {
    @Published var devices: [Device] = []
    @Published var isScanning: Bool = false
    @Published var progress: Double = 0.0
    @Published var lastAddress: String = ""
    @Published var errorMessage: String?

    private let scanner: DeviceScanner
    private let history: HistoryRepository

    init(scanner: DeviceScanner, history: HistoryRepository) {
        self.scanner = scanner
        self.history = history
    }

    func startScan(duration: TimeInterval = 150) {
        guard !isScanning else { return }

        let startedAt = Date()

        errorMessage = nil
        devices = []
        progress = 0
        lastAddress = ""
        isScanning = true

        Task {
            do {
                let scanned = try await scanner.startScanning(duration: duration)
                let finishedAt = Date()

                let session = ScanSession(
                    type: .lan,
                    startedAt: startedAt,
                    finishedAt: finishedAt,
                    devices: scanned
                )

                do {
                    if scanned.isEmpty {
                        errorMessage = "Устройства не найдены. Проверь Wi-Fi и доступ к локальной сети."
                    } else {
                        try? history.saveSession(session)
                        print("✅ Saved session \(session.id) devices: \(session.devices.count)")
                    }
                } catch {
                    errorMessage = "Скан выполнен, но не удалось сохранить: \(error.localizedDescription)"
                }

                devices = scanned.sorted { $0.id < $1.id }
            } catch {
                errorMessage = error.localizedDescription
            }

            isScanning = false
        }
    }

    func stopScan() {
        scanner.stopScanning()
        isScanning = false
    }

    func updateProgress(_ value: Double, address: String) {
        progress = min(max(value, 0), 1)
        lastAddress = address
    }
}
