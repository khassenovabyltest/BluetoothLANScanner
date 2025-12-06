//
//  HistoryViewModel.swift
//  BluetoothLANScanner
//
//  Created by Abylbek Khassenov on 05.12.2025.
//

import Foundation

@MainActor
final class HistoryViewModel: ObservableObject {
    @Published var sessions: [ScanSession] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    @Published var deviceNameQuery: String = ""
    @Published var dateFromEnabled: Bool = false
    @Published var dateToEnabled: Bool = false
    @Published var dateFrom: Date = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
    @Published var dateTo: Date = Date()

    private let history: HistoryRepository

    init(history: HistoryRepository) {
        self.history = history
    }

    func load() {
        isLoading = true
        errorMessage = nil

        let filter = buildFilter()

        do {
            sessions = try history.fetchSessions(filter: filter)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func clearFilters() {
        deviceNameQuery = ""
        dateFromEnabled = false
        dateToEnabled = false
        dateFrom = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        dateTo = Date()
        load()
    }

    private func buildFilter() -> ScanSessionFilter? {
        let trimmed = deviceNameQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        let name = trimmed.isEmpty ? nil : trimmed

        let from = dateFromEnabled ? dateFrom : nil
        let to = dateToEnabled ? dateTo : nil

        if name == nil && from == nil && to == nil { return nil }
        return ScanSessionFilter(deviceNameContains: name, dateFrom: from, dateTo: to)
    }
}
