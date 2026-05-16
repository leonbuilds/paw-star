// PawStar/Features/Preview/AIInferenceView.swift
import SwiftUI
import SwiftData

struct AIInferenceView: View {
    let pet: PetProfile
    let certType: CertificateType
    @Environment(\.modelContext) private var modelContext
    @State private var phase: InferencePhase = .loading(progress: 0)
    @State private var progress: Double = 0
    private let timer = Timer.publish(every: 0.08, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            Theme.Color.warmWhite.ignoresSafeArea()
            VStack(spacing: 32) {
                Spacer()
                pawAnimation
                statusText
                Spacer()
                if case .success(let payload) = phase {
                    NavigationLink(destination: cardView(payload: payload)) {
                        Text("查看鉴定书 🎉")
                            .font(Theme.Font.cardTitle())
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Theme.Color.primary)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .padding(.horizontal, 32)
                    }
                }
                if case .fallback(let payload) = phase {
                    NavigationLink(destination: cardView(payload: payload)) {
                        VStack(spacing: 4) {
                            Text("查看鉴定书（离线版）")
                                .font(Theme.Font.cardTitle())
                                .foregroundStyle(.white)
                            Text("网络不给力，用了备用结果")
                                .font(Theme.Font.caption())
                                .foregroundStyle(.white.opacity(0.8))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Theme.Color.primaryDark)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal, 32)
                    }
                }
            }
        }
        .navigationTitle("鉴定中...")
        .navigationBarBackButtonHidden(isLoading)
        .onReceive(timer) { _ in updateProgress() }
        .task { await runInference() }
    }

    private var isLoading: Bool {
        if case .loading = phase { return true }
        return false
    }

    private var pawAnimation: some View {
        ZStack {
            Circle()
                .stroke(Theme.Color.border, lineWidth: 6)
                .frame(width: 120, height: 120)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(Theme.Color.primary, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                .frame(width: 120, height: 120)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.1), value: progress)
            Text("🐾")
                .font(.system(size: 48))
                .scaleEffect(isLoading ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: isLoading)
        }
    }

    private var statusText: some View {
        VStack(spacing: 8) {
            switch phase {
            case .loading:
                Text("小爪印盖章中…")
                    .font(Theme.Font.cardTitle())
                    .foregroundStyle(Theme.Color.textPrimary)
                Text("AI 鉴定师正在认真分析，请稍候")
                    .font(Theme.Font.body())
                    .foregroundStyle(Theme.Color.textSecondary)
            case .success:
                Text("鉴定完成！")
                    .font(Theme.Font.cardTitle())
                    .foregroundStyle(Theme.Color.primary)
            case .fallback:
                Text("鉴定完成（备用结果）")
                    .font(Theme.Font.cardTitle())
                    .foregroundStyle(Theme.Color.primaryDark)
            }
        }
        .multilineTextAlignment(.center)
    }

    private func updateProgress() {
        guard isLoading, progress < 0.9 else { return }
        progress += 0.005
    }

    private func runInference() async {
        guard let imageData = pet.avatarImageData else {
            useFallback()
            return
        }

        do {
            let payload = try await NetworkService.shared.certify(
                type: certType,
                imageData: imageData,
                category: pet.category
            )
            let encoded = (try? JSONEncoder().encode(payload)) ?? Data()
            let record = CertificateRecord(
                type: certType,
                serialNumber: SerialNumberGenerator.generate(),
                aiResultData: encoded
            )
            record.pet = pet
            modelContext.insert(record)
            progress = 1.0
            phase = .success(payload)
        } catch {
            useFallback()
        }
    }

    private func useFallback() {
        let payload = FallbackProvider.result(for: certType, category: pet.category)
        let encoded = (try? JSONEncoder().encode(payload)) ?? Data()
        let record = CertificateRecord(
            type: certType,
            serialNumber: SerialNumberGenerator.generate(),
            aiResultData: encoded
        )
        record.pet = pet
        modelContext.insert(record)
        progress = 1.0
        phase = .fallback(payload)
    }

    @ViewBuilder
    private func cardView(payload: AIResultPayload) -> some View {
        let encoded = (try? JSONEncoder().encode(payload)) ?? Data()
        let record = CertificateRecord(type: certType, serialNumber: SerialNumberGenerator.generate(), aiResultData: encoded)
        switch certType {
        case .pedigree: PedigreeCardView(record: record)
        case .beauty: BeautyCardView(record: record)
        case .personality: PersonalityCardView(record: record)
        }
    }
}

enum InferencePhase {
    case loading(progress: Double)
    case success(AIResultPayload)
    case fallback(AIResultPayload)
}

#Preview {
    NavigationStack {
        AIInferenceView(
            pet: PetProfile(name: "橘猫小明", category: .cat, birthday: Date()),
            certType: .pedigree
        )
    }
}
