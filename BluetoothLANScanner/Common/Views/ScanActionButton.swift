//
//  ScanActionButton.swift
//  BluetoothLANScanner
//
//  Created by Abylbek Khassenov on 05.12.2025.
//

import SwiftUI
import Lottie

struct ScanActionButton: View {
    let isScanning: Bool
    let title: String
    let systemImage: String
    let progress: Double?
    let size: CGFloat
    let action: () -> Void

    private var clampedProgress: Double {
        min(max(progress ?? 0, 0), 1)
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    if isScanning, progress != nil {
                        Circle()
                            .trim(from: 0, to: clampedProgress)
                            .stroke(
                                Color.white.opacity(0.9),
                                style: StrokeStyle(lineWidth: 10, lineCap: .round)
                            )
                            .frame(width: size, height: size)
                            .rotationEffect(.degrees(-90))
                            .animation(.easeInOut(duration: 0.2), value: clampedProgress)
                    }
                    
                    Circle()
                        .fill(.ultraThinMaterial)
                        .overlay(
                            Circle().strokeBorder(.white.opacity(0.22), lineWidth: 1)
                        )
                        .frame(width: size, height: size)
                        .shadow(radius: 10)

                    if isScanning {
                        LottieView(name: "Loading", loopMode: .loop, speed: 1.2)
                            .frame(width: 44, height: 44)
                    } else {
                        Image(systemName: systemImage)
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.90))
                    }
                }

                Text(title)
                    .font(.title2)
                    .foregroundStyle(.white.opacity(0.85))
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
    }
}

extension ScanActionButton {
    enum Mode { case bluetooth, lan }

    init(mode: Mode, isScanning: Bool, progress: Double? = nil, size: CGFloat = 150, action: @escaping () -> Void) {
        self.isScanning = isScanning
        self.progress = progress
        self.size = size
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
