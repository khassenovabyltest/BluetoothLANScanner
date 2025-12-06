//
//  ScanActionButton.swift
//  BluetoothLANScanner
//
//  Created by Abylbek Khassenov on 05.12.2025.
//

import SwiftUI

struct ScanActionButton: View {
    let isScanning: Bool
    let title: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .overlay(
                            Circle().strokeBorder(.white.opacity(0.22), lineWidth: 1)
                        )
                        .frame(width: 76, height: 76)
                        .shadow(radius: 10)

                    Image(systemName: systemImage)
                        .font(.system(size: 28, weight: .semibold))
                }

                Text(title)
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.85))
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
    }
}

extension ScanActionButton {
    enum Mode {
        case bluetooth
        case lan
    }

    init(mode: Mode, isScanning: Bool, action: @escaping () -> Void) {
        self.isScanning = isScanning
        self.title = isScanning ? "Стоп" : "Сканировать"

        switch mode {
        case .bluetooth:
            self.systemImage = isScanning ? "stop.fill" : "dot.radiowaves.left.and.right"
        case .lan:
            self.systemImage = isScanning ? "stop.fill" : "wifi"
        }

        self.action = action
    }
}
