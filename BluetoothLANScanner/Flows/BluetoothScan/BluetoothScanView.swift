//
//  BluetoothScanView.swift
//  BluetoothLANScanner
//
//  Created by Abylbek Khassenov on 04.12.2025.
//

import SwiftUI

struct BluetoothScanView: View {
    @StateObject private var viewModel: BluetoothScanViewModel

    init(viewModel: BluetoothScanViewModel? = nil) {
        if let viewModel {
            _viewModel = StateObject(wrappedValue: viewModel)
        } else {
            let scanner = BluetoothScannerService()
            let history = CoreDataHistoryRepository()
            _viewModel = StateObject(wrappedValue: BluetoothScanViewModel(scanner: scanner, history: history))
        }
    }

    var body: some View {
        ZStack {
            AppBackgroundView()
                .ignoresSafeArea()

            if viewModel.devices.isEmpty {
                ScanActionButton(mode: .bluetooth, isScanning: viewModel.isScanning, progress: viewModel.progress) {
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
                    ScanActionButton(mode: .bluetooth, isScanning: viewModel.isScanning, progress: viewModel.progress, size: 50) {
                        viewModel.isScanning ? viewModel.stopScan() : viewModel.startScan(duration: 15)
                    }
                    .padding(.bottom, 120)
                }
            }
        }
        .navigationTitle("Bluetooth Сканер")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(.hidden, for: .navigationBar)
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
        .alert("Готово", isPresented: Binding(
            get: { viewModel.completionMessage != nil },
            set: { if !$0 { viewModel.completionMessage = nil } }
        )) {
            Button("OK", role: .cancel) { viewModel.completionMessage = nil }
        } message: {
            Text(viewModel.completionMessage ?? "")
        }
    }
}
