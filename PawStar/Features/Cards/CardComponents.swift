// PawStar/Features/Cards/CardComponents.swift
import SwiftUI

// MARK: - 渐变头部 Banner
struct CardBanner: View {
    let title: String
    let english: String
    let gradient: [Color]

    var body: some View {
        ZStack {
            LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
            // 装饰圆圈
            Circle().fill(.white.opacity(0.08)).frame(width: 120).offset(x: 110, y: -30)
            Circle().fill(.white.opacity(0.06)).frame(width: 80).offset(x: -100, y: 20)
            VStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text(english)
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.75))
                    .tracking(1.5)
            }
            .padding(.top, 4)
        }
        .frame(height: 88)
    }
}

// MARK: - 圆形头像（覆盖在 Banner 底部）
struct CardAvatar: View {
    let name: String
    let serialNumber: String
    let avatarData: Data?
    let ringColor: Color

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(.white)
                    .frame(width: 92, height: 92)
                    .shadow(color: ringColor.opacity(0.3), radius: 8)
                Circle()
                    .strokeBorder(LinearGradient(colors: [ringColor, ringColor.opacity(0.4)],
                                                startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 3)
                    .frame(width: 92, height: 92)
                if let data = avatarData, let img = UIImage(data: data) {
                    Image(uiImage: img)
                        .resizable().scaledToFill()
                        .frame(width: 84, height: 84).clipShape(Circle())
                } else {
                    Text("🐾").font(.system(size: 36))
                }
            }
            Text(name)
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.Color.textPrimary)
            Text(serialNumber)
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .foregroundStyle(Theme.Color.textSecondary.opacity(0.7))
                .tracking(0.5)
        }
    }
}

// MARK: - 等级徽章（大型圆形）
struct GradeBadge: View {
    let grade: String
    let color: Color

    var body: some View {
        ZStack {
            Circle()
                .fill(LinearGradient(colors: [color, color.opacity(0.6)],
                                     startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 64, height: 64)
                .shadow(color: color.opacity(0.4), radius: 8)
            Text(grade)
                .font(.system(size: grade.count > 2 ? 16 : 22, weight: .black, design: .rounded))
                .foregroundStyle(.white)
        }
    }
}

// MARK: - 细装饰分隔线
struct CardDivider: View {
    let color: Color
    var body: some View {
        HStack(spacing: 8) {
            Rectangle().fill(color.opacity(0.3)).frame(height: 1)
            Circle().fill(color).frame(width: 4, height: 4)
            Rectangle().fill(color.opacity(0.3)).frame(height: 1)
        }
    }
}

// MARK: - 底部（仅供娱乐 + 水印 + 日期）
struct CardFooter: View {
    var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: 0) {
                Rectangle().fill(Theme.Color.border.opacity(0.5)).frame(height: 0.5)
            }
            HStack {
                // 仅供娱乐印章
                Text("仅供娱乐")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(.red)
                    .padding(.horizontal, 7).padding(.vertical, 3)
                    .overlay(RoundedRectangle(cornerRadius: 4).stroke(.red, lineWidth: 1.2))
                Spacer()
                VStack(alignment: .trailing, spacing: 1) {
                    Text("made with PawStar")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(Theme.Color.textSecondary.opacity(0.4))
                    Text(Date().formatted(.dateTime.year().month().day()))
                        .font(.system(size: 9))
                        .foregroundStyle(Theme.Color.textSecondary.opacity(0.3))
                }
            }
        }
    }
}

// MARK: - 属性行
struct AttrRow: View {
    let key: String
    let value: String
    let accent: Color

    var body: some View {
        HStack {
            Circle().fill(accent.opacity(0.5)).frame(width: 5, height: 5)
            Text(key)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(Theme.Color.textSecondary)
            Spacer()
            Text(value)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(Theme.Color.textPrimary)
        }
    }
}

// MARK: - 引言框（description）
struct QuoteBox: View {
    let text: String
    let accent: Color

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            RoundedRectangle(cornerRadius: 2).fill(accent).frame(width: 3)
            Text(text)
                .font(.system(size: 13, weight: .regular, design: .rounded))
                .foregroundStyle(Theme.Color.textSecondary)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .background(accent.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
