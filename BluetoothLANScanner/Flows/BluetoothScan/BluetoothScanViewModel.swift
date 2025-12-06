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
    @Published var progress: Double = 0.0
    @Published var errorMessage: String?
    @Published var completionMessage: String?

    private let scanner: DeviceScanner
    private let history: HistoryRepository

    private var progressTask: Task<Void, Never>?
    private var stopTask: Task<Void, Never>?

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
        progress = 0

        progressTask?.cancel()
        progressTask = Task { [weak self] in
            guard let self else { return }
            while !Task.isCancelled && self.isScanning {
                let elapsed = Date().timeIntervalSince(startedAt)
                self.progress = min(max(elapsed / max(duration, 0.1), 0), 1)
                try? await Task.sleep(nanoseconds: 100_000_000)
            }
        }

        stopTask?.cancel()
        stopTask = Task { [weak self] in
            guard let self else { return }
            try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
            self.scanner.stopScanning() 
        }

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
                try? history.saveSession(session)

                devices = scanned.sorted { ($0.rssi ?? -100) > ($1.rssi ?? -100) }
                progress = 1.0
                completionMessage = "Сканирование завершено. Найдено устройств: \(devices.count)"
            } catch {
                errorMessage = error.localizedDescription
            }

            isScanning = false
            isLoading = false

            progressTask?.cancel()
            progressTask = nil

            stopTask?.cancel()
            stopTask = nil
        }
    }

    func stopScan() {
        guard isScanning else { return }

        scanner.stopScanning()

        isScanning = false
        isLoading = false
        progress = 1.0

        progressTask?.cancel()
        progressTask = nil

        stopTask?.cancel()
        stopTask = nil
    }
}
