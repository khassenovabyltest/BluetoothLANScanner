//
//  AppBackgroundView.swift
//  BluetoothLANScanner
//
//  Created by Abylbek Khassenov on 05.12.2025.
//


import SwiftUI

struct AppBackgroundView: View {
    var body: some View {
        Image("background")
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()
            .overlay(Color.black.opacity(0.06))
    }
}
