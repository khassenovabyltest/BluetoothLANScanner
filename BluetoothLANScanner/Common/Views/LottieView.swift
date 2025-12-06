//
//  LottieView.swift
//  BluetoothLANScanner
//
//  Created by Abylbek Khassenov on 06.12.2025.
//

import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {
    let name: String
    var loopMode: LottieLoopMode = .loop
    var speed: CGFloat = 1.0

    func makeUIView(context: Context) -> LottieAnimationView {
        let view = LottieAnimationView(name: name)
        view.loopMode = loopMode
        view.animationSpeed = speed
        view.backgroundBehavior = .pauseAndRestore
        view.contentMode = .scaleAspectFit
        view.play()
        return view
    }

    func updateUIView(_ uiView: LottieAnimationView, context: Context) {
        uiView.loopMode = loopMode
        uiView.animationSpeed = speed

        if !uiView.isAnimationPlaying {
            uiView.play()
        }
    }
}
