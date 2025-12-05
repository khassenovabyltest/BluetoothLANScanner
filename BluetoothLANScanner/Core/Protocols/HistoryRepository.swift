//
//  HistoryRepository.swift
//  BluetoothLANScanner
//
//  Created by Abylbek Khassenov on 04.12.2025.
//

import Foundation

public struct ScanSessionFilter: Hashable {
    public var deviceNameContains: String?
    public var dateFrom: Date?
    public var dateTo: Date?

    public init(deviceNameContains: String? = nil, dateFrom: Date? = nil, dateTo: Date? = nil) {
        self.deviceNameContains = deviceNameContains
        self.dateFrom = dateFrom
        self.dateTo = dateTo
    }
}

public protocol HistoryRepository {
    func saveSession(_ session: ScanSession) throws
    func fetchSessions(filter: ScanSessionFilter?) throws -> [ScanSession]
    func fetchSession(id: UUID) throws -> ScanSession?
    func deleteSession(id: UUID) throws
}
