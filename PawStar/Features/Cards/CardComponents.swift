// PawStar/Features/Cards/CardComponents.swift
import SwiftUI

struct CardHeader: View {
    let title: String
    let english: String
    var body: some View {
        VStack(spacing: 4) {
            Text(title).font(Theme.Font.cardTitle(18)).foregroundStyle(Theme.Color.textPrimary)
            Text(english).font(Theme.Font.caption(11)).foregroundStyle(Theme.Color.textSecondary)
            Rectangle().fill(Theme.Color.certGold).frame(height: 1).padding(.top, 4)
        }
    }
}

struct CardPhotoSection: View {
    let petName: String
    let serialNumber: String
    let avatarData: Data?
    var body: some View {
        HStack(spacing: 16) {
            Group {
                if let data = avatarData, let img = UIImage(data: data) {
                    Image(uiImage: img).resizable().scaledToFill()
                } else {
                    Image(systemName: "pawprint.fill").font(.system(size: 32)).foregroundStyle(Theme.Color.primary)
                }
            }
            .frame(width: 80, height: 80)
            .clipShape(Circle())
            .overlay(Circle().strokeBorder(Theme.Color.certGold, lineWidth: 2))
            VStack(alignment: .leading, spacing: 4) {
                Text(petName).font(Theme.Font.cardTitle()).foregroundStyle(Theme.Color.textPrimary)
                Text(serialNumber).font(Theme.Font.mono(11)).foregroundStyle(Theme.Color.textSecondary)
            }
            Spacer()
        }
    }
}

struct CardDivider: View {
    var body: some View {
        Rectangle().fill(Theme.Color.certGold.opacity(0.4)).frame(height: 1)
    }
}

struct ToyBadge: View {
    var body: some View {
        Text("仅供娱乐")
            .font(Theme.Font.caption(9)).foregroundStyle(.white)
            .padding(.horizontal, 6).padding(.vertical, 3)
            .background(Color.red).clipShape(RoundedRectangle(cornerRadius: 4))
    }
}

struct CardFooter: View {
    var body: some View {
        VStack(spacing: 4) {
            CardDivider()
            HStack {
                ToyBadge()
                Spacer()
                Text("made with PawStar")
                    .font(Theme.Font.caption(10))
                    .foregroundStyle(Theme.Color.textSecondary.opacity(0.4))
            }
        }
    }
}

struct GradeTag: View {
    let grade: String
    var body: some View {
        Text(grade)
            .font(Theme.Font.caption(12)).fontWeight(.bold).foregroundStyle(Theme.Color.certGold)
            .padding(.horizontal, 10).padding(.vertical, 4)
            .background(Theme.Color.certGold.opacity(0.15))
            .clipShape(Capsule())
            .overlay(Capsule().strokeBorder(Theme.Color.certGold, lineWidth: 1))
    }
}
