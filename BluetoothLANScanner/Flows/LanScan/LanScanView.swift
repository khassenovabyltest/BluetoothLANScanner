//
//  LanScanView.swift
//  BluetoothLANScanner
//
//  Created by Abylbek Khassenov on 04.12.2025.
//

import SwiftUI

struct LanScanView: View {
    @StateObject private var viewModel: LanScanViewModel

    init(viewModel: LanScanViewModel? = nil) {
        if let viewModel {
            _viewModel = StateObject(wrappedValue: viewModel)
            return
        }

        let service = LanScannerService()
        let history = CoreDataHistoryRepository()
        let vm = LanScanViewModel(scanner: service, history: history)

        service.onProgress = { progress, address in
            Task { @MainActor in
                vm.updateProgress(progress, address: address)
            }
        }

        _viewModel = StateObject(wrappedValue: vm)
    }

    var body: some View {
        ZStack {
            AppBackgroundView()
                .ignoresSafeArea()

            if viewModel.devices.isEmpty {
                ScanActionButton(mode: .lan, isScanning: viewModel.isScanning, progress: viewModel.progress) {
                    viewModel.isScanning ? viewModel.stopScan() : viewModel.startScan(duration: 15)
                }
            } else {
                List(viewModel.devices) { device in
                    NavigationLink {
                        DeviceDetailView(device: device)
                    } label: {
                        DeviceRowView(device: device)
                    }
                    .listRowBackground(Color.clear)
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .padding(.top, 120)

                VStack {
                    Spacer()
                    ScanActionButton(mode: .lan, isScanning: viewModel.isScanning, progress: viewModel.progress, size: 50) {
                        viewModel.isScanning ? viewModel.stopScan() : viewModel.startScan(duration: 15)
                    }
                    .padding(.bottom, 86)
                }
            }

            if viewModel.isScanning {
                VStack {
                    ProgressView(value: viewModel.progress)
                        .padding(.horizontal)
                        .padding(.top, 10)
                    Spacer()
                }
            }
        }
        .navigationTitle("LAN Сканер")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)

        .onDisappear {
            if viewModel.isScanning { viewModel.stopScan() }
        }
        .alert("Ошибка", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
}
