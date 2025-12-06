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
                ScanActionButton(mode: .bluetooth, isScanning: viewModel.isScanning) {
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


                VStack {
                    Spacer()
                    ScanActionButton(mode: .bluetooth, isScanning: viewModel.isScanning) {
                        viewModel.isScanning ? viewModel.stopScan() : viewModel.startScan(duration: 15)
                    }
                    .padding(.bottom, 86) 
                }
            }
        }
        .navigationTitle("Bluetooth Сканер")
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
