//
//  PrimaryButtonStyle.swift
//  ChartWallet
//
//  Created by DY on 6/10/25.
//

import SwiftUI

// MARK: - Button Styles
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
