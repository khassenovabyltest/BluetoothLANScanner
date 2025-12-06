//
//  HistoryView.swift
//  BluetoothLANScanner
//
//  Created by Abylbek Khassenov on 05.12.2025.
//

import SwiftUI

struct HistoryView: View {
    @StateObject private var viewModel: HistoryViewModel

    init() {
        let repo = CoreDataHistoryRepository()
        _viewModel = StateObject(wrappedValue: HistoryViewModel(history: repo))
    }

    var body: some View {
        ZStack {
            AppBackgroundView()
                .ignoresSafeArea()

            VStack(spacing: 12) {

                Spacer(minLength: 100)
                filtersBlock
                    .padding(.top, 8)
                    .padding(.horizontal, 16)

                if viewModel.isLoading {
                    Spacer()
                    ProgressView()
                    Spacer()
                } else if viewModel.sessions.isEmpty {
                    Spacer()
                    ContentUnavailableView("История пуста", systemImage: "clock.arrow.circlepath")
                    Spacer()
                } else {
                    List(viewModel.sessions) { session in
                        NavigationLink {
                            SessionDetailView(sessionId: session.id)
                        } label: {
                            sessionRow(session)
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
        }
        .navigationTitle("История")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Обновить") { viewModel.load() }
            }
        }
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

    // MARK: - Filters

    private var filtersBlock: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                TextField("Фильтр по имени устройства", text: $viewModel.deviceNameQuery)
                    .textFieldStyle(.roundedBorder)

                Button("Найти") { viewModel.load() }
                    .disabled(viewModel.deviceNameQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }

            HStack {
                Toggle("Фильтр: дата от", isOn: $viewModel.dateFromEnabled)
                Toggle("Фильтр: дата до", isOn: $viewModel.dateToEnabled)
            }

            HStack(spacing: 12) {
                if viewModel.dateFromEnabled {
                    DatePicker("", selection: $viewModel.dateFrom, displayedComponents: .date)
                        .labelsHidden()
                }

                if viewModel.dateToEnabled {
                    DatePicker("", selection: $viewModel.dateTo, displayedComponents: .date)
                        .labelsHidden()
                }

                Spacer()

                Button("Сброс") { viewModel.clearFilters() }
                    .buttonStyle(.bordered)
            }
        }
        .padding(12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: - Row

    private func sessionRow(_ session: ScanSession) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(session.type.rawValue.capitalized)
                .font(.headline)

            Text("Устройств: \(session.devices.count)")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text("Дата: \(session.finishedAt.formatted(date: .abbreviated, time: .shortened))")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .background(Color.clear)
        .padding(.vertical, 4)
    }
}

