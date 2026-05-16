// PawStar/Theme/Theme.swift
import SwiftUI

enum Theme {
    enum Color {
        // 暖橙主色（方案 C 奶油绒感）
        static let primary = SwiftUI.Color(hex: "#FF8A3D")
        static let primaryDark = SwiftUI.Color(hex: "#E5701F")
        // 樱花粉（方案 C 新增）
        static let sakuraPink = SwiftUI.Color(hex: "#FFC2D1")
        // 证件金
        static let certGold = SwiftUI.Color(hex: "#FFCB47")
        // 暖白背景
        static let warmWhite = SwiftUI.Color(hex: "#FFF8F0")
        // 卡片白
        static let cardWhite = SwiftUI.Color(hex: "#FFFFFF")
        // 文字
        static let textPrimary = SwiftUI.Color(hex: "#1A1A1A")
        static let textSecondary = SwiftUI.Color(hex: "#6B6B6B")
        // 边框
        static let border = SwiftUI.Color(hex: "#E8D5C4")
        // Liquid Glass tint（樱花粉 6%）
        static let glassTint = SwiftUI.Color(hex: "#FFC2D1").opacity(0.06)
    }

    enum Font {
        static func title(_ size: CGFloat = 28) -> SwiftUI.Font {
            .system(size: size, weight: .bold, design: .rounded)
        }
        static func cardTitle(_ size: CGFloat = 20) -> SwiftUI.Font {
            .system(size: size, weight: .semibold, design: .rounded)
        }
        static func body(_ size: CGFloat = 16) -> SwiftUI.Font {
            .system(size: size, weight: .regular, design: .rounded)
        }
        static func caption(_ size: CGFloat = 12) -> SwiftUI.Font {
            .system(size: size, weight: .medium, design: .rounded)
        }
        static func mono(_ size: CGFloat = 13) -> SwiftUI.Font {
            .system(size: size, weight: .regular, design: .monospaced)
        }
    }
}

// MARK: - Hex Color 扩展
extension SwiftUI.Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 6:
            (r, g, b) = ((int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (0, 0, 0)
        }
        self.init(red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255)
    }
}

// MARK: - Liquid Glass 扩展（WORKFLOW 附录 C）
// iOS 26 新 API，低版本 fallback .regularMaterial
extension View {
    @ViewBuilder
    func liquidGlass(tint: SwiftUI.Color = Theme.Color.glassTint, cornerRadius: CGFloat = 20) -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(.regular.tint(tint), in: .rect(cornerRadius: cornerRadius))
        } else {
            self
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        }
    }
}
