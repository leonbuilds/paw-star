// PawStar/Features/Home/HomeView.swift
import SwiftUI
import SwiftData

struct HomeView: View {
    @State private var vm = HomeViewModel()
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                VStack(spacing: 0) {
                    HeaderBar()
                    ScrollView {
                        VStack(spacing: 12) {
                            EntryCard(type: .pedigree)
                            EntryCard(type: .beauty)
                            EntryCard(type: .personality)
                        }
                        .padding(20)
                        .padding(.bottom, 80)
                    }
                }
                .background(Theme.Color.warmWhite)
                GlassTabBar()
            }
        }
    }
}

private struct HeaderBar: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("PawPedigree 鉴定馆")
                .font(Theme.Font.title())
                .foregroundStyle(Theme.Color.primary)
            Text("给家里的小明星办张鉴定书")
                .font(Theme.Font.body())
                .foregroundStyle(Theme.Color.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 12)
    }
}

private struct EntryCard: View {
    let type: CertificateType

    private var icon: String {
        switch type {
        case .pedigree: return "🏅"
        case .beauty: return "✨"
        case .personality: return "🎭"
        }
    }

    private var subtitle: String {
        switch type {
        case .pedigree: return "探索家族基因，解密血统密码"
        case .beauty: return "AI 严肃评分，科学界定美丑"
        case .personality: return "深度解析性格，找出独特标签"
        }
    }

    var body: some View {
        NavigationLink(destination: PhotoPickerView(certType: type)) {
            HStack(spacing: 16) {
                Text(icon)
                    .font(.system(size: 36))
                VStack(alignment: .leading, spacing: 4) {
                    Text(type.displayName)
                        .font(Theme.Font.cardTitle())
                        .foregroundStyle(Theme.Color.textPrimary)
                    Text(subtitle)
                        .font(Theme.Font.caption())
                        .foregroundStyle(Theme.Color.textSecondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(Theme.Color.textSecondary)
                    .font(.system(size: 14, weight: .semibold))
            }
            .padding(20)
            .background(Theme.Color.cardWhite)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
}

private struct GlassTabBar: View {
    var body: some View {
        HStack(spacing: 0) {
            TabItemView(icon: "🏠", label: "鉴定馆", active: true)
            TabItemView(icon: "📖", label: "我的本本", active: false)
        }
        .padding(.horizontal, 24)
        .frame(height: 56)
        .liquidGlass(cornerRadius: 28)
        .padding(.horizontal, 12)
        .padding(.bottom, 12)
    }
}

private struct TabItemView: View {
    let icon: String
    let label: String
    let active: Bool

    var body: some View {
        HStack(spacing: 6) {
            Text(icon).font(.system(size: 18))
            Text(label)
                .font(Theme.Font.caption())
                .foregroundStyle(active ? Theme.Color.primary : Theme.Color.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    HomeView()
}
