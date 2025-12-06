//
//  SessionDetailViewModel.swift
//  BluetoothLANScanner
//
//  Created by Abylbek Khassenov on 05.12.2025.
//

import Foundation

@MainActor
final class SessionDetailViewModel: ObservableObject {
    @Published var session: ScanSession?
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false

    private let history: HistoryRepository
    private let sessionId: UUID

    init(sessionId: UUID, history: HistoryRepository) {
        self.sessionId = sessionId
        self.history = history
    }

    func load() {
        isLoading = true
        errorMessage = nil

        do {
            session = try history.fetchSession(id: sessionId)
            if session == nil {
                errorMessage = "Сессия не найдена"
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
