//
//  SessionDetailView.swift
//  BluetoothLANScanner
//
//  Created by Abylbek Khassenov on 05.12.2025.
//

import SwiftUI

struct SessionDetailView: View {
    @StateObject private var viewModel: SessionDetailViewModel

    init(sessionId: UUID) {
        let repo = CoreDataHistoryRepository()
        _viewModel = StateObject(wrappedValue: SessionDetailViewModel(sessionId: sessionId, history: repo))
    }

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Загрузка...")
            } else if let session = viewModel.session {
                List {
                    Section("Информация") {
                        row("Тип", session.type == .bluetooth ? "Bluetooth" : "LAN")
                        row("Начало", session.startedAt.formatted(date: .abbreviated, time: .standard))
                        row("Конец", session.finishedAt.formatted(date: .abbreviated, time: .standard))
                        row("Длительность", "\(Int(session.duration)) сек")
                        row("Устройств", "\(session.deviceCount)")
                    }

                    Section("Устройства") {
                        ForEach(session.devices) { device in
                            NavigationLink {
                                DeviceDetailView(device: device)
                            } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(device.name.isEmpty ? "Unknown" : device.name)
                                        .font(.headline)

                                    Text(device.primaryIdentifier)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)

                                    if let rssi = device.rssi, session.type == .bluetooth {
                                        Text("RSSI: \(rssi)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }

                                    if let mac = device.mac, !mac.isEmpty {
                                        Text("MAC: \(mac)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }

                                    if let brand = device.brand, !brand.isEmpty {
                                        Text("Brand: \(brand)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                }
            } else {
                ContentUnavailableView("Нет данных", systemImage: "exclamationmark.triangle")
            }
        }
        .navigationTitle("Сканирование")
        .onAppear { viewModel.load() }
        .alert("Ошибка", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    private func row(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value).foregroundStyle(.white.opacity(0.85))
        }
    }
}
