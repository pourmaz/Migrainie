//
//  Theme.swift
//  Migrainie
//
//  Created by Pourya Mazinani on 04/12/25.
//
import SwiftUI

// MARK: - Color helper from hex

extension Color {
    init(hex: String) {
        var hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)

        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255,
                            (int >> 8) * 17,
                            (int >> 4 & 0xF) * 17,
                            (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255,
                            int >> 16,
                            int >> 8 & 0xFF,
                            int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24,
                            int >> 16 & 0xFF,
                            int >> 8 & 0xFF,
                            int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - App theme using your palette

struct AppTheme {
    /// #728156 – deep green for primary actions
    static let primary = Color(hex: "#728156")
    /// #98A77C – softer secondary accents
    static let secondary = Color(hex: "#98A77C")
    /// #E7F5DC – light background
    static let background = Color(hex: "#E7F5DC")
    /// #CFE1B9 – card backgrounds
    static let card = Color(hex: "#CFE1B9")
    /// #88976C – subdued text / icons if needed
    static let muted = Color(hex: "#88976C")
    
    static let cornerRadius: CGFloat = 18
    static let shadowRadius: CGFloat = 10
}

extension View {
    func cardStyle() -> some View {
        self
            .padding()
            .background(AppTheme.card)
            .cornerRadius(AppTheme.cornerRadius)
            .shadow(color: Color.black.opacity(0.06),
                    radius: AppTheme.shadowRadius,
                    x: 0, y: 4)
    }
}

