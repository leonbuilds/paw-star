// PawStar/App/PawStarApp.swift
import SwiftUI
import SwiftData

@main
struct PawStarApp: App {
    static let sharedContainer: ModelContainer = {
        let schema = Schema([PetProfile.self, CertificateRecord.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("ModelContainer 创建失败: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootView()
                .preferredColorScheme(.light)
        }
        .modelContainer(PawStarApp.sharedContainer)
    }
}

struct RootView: View {
    var body: some View {
        Text("PawPedigree · 即将上线 🐾")
            .font(Theme.Font.title())
            .foregroundStyle(Theme.Color.primary)
    }
}
