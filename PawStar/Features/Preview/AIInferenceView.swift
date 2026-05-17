// PawStar/Features/Preview/AIInferenceView.swift
import SwiftUI
import SwiftData

struct AIInferenceView: View {
    let pet: PetProfile
    let certType: CertificateType
    @Environment(\.modelContext) private var modelContext
    @State private var phase: InferencePhase = .loading
    @State private var progress: Double = 0
    @State private var savedRecord: CertificateRecord?
    private let timer = Timer.publish(every: 0.06, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            Theme.Color.warmWhite.ignoresSafeArea()
            VStack(spacing: 32) {
                Spacer()
                pawAnimation
                statusText
                Spacer()
                if let record = savedRecord, phase != .loading {
                    NavigationLink(destination: cardView(record: record)) {
                        VStack(spacing: 4) {
                            Text(phase == .success ? "查看鉴定书 🎉" : "查看鉴定书（离线版）")
                                .font(Theme.Font.cardTitle())
                                .foregroundStyle(.white)
                            if phase == .fallback {
                                Text("网络开小差，已生成备用结果")
                                    .font(Theme.Font.caption())
                                    .foregroundStyle(.white.opacity(0.8))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(phase == .success ? Theme.Color.primary : Theme.Color.primaryDark)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal, 32)
                    }
                }
            }
        }
        .navigationTitle("鉴定中...")
        .navigationBarBackButtonHidden(phase == .loading)
        .onReceive(timer) { _ in
            guard phase == .loading, progress < 0.92 else { return }
            progress += 0.004
        }
        .task { await runInference() }
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
                .animation(.linear(duration: 0.1), value: progress)
            Text("🐾")
                .font(.system(size: 48))
                .scaleEffect(phase == .loading ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: phase == .loading)
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

    private func runInference() async {
        guard let imageData = pet.avatarImageData else {
            useFallback(); return
        }
        do {
            let payload = try await NetworkService.shared.certify(
                type: certType, imageData: imageData, category: pet.category
            )
            let record = saveRecord(payload: payload)
            savedRecord = record
            withAnimation { progress = 1.0 }
            phase = .success
        } catch {
            useFallback()
        }
    }

    private func useFallback() {
        let payload = FallbackProvider.result(for: certType, category: pet.category)
        let record = saveRecord(payload: payload)
        savedRecord = record
        withAnimation { progress = 1.0 }
        phase = .fallback
    }

    // 保存 record 并绑定 pet，供 cardView 直接使用
    @discardableResult
    private func saveRecord(payload: AIResultPayload) -> CertificateRecord {
        let encoded = (try? JSONEncoder().encode(payload)) ?? Data()
        let record = CertificateRecord(
            type: certType,
            serialNumber: SerialNumberGenerator.generate(),
            aiResultData: encoded
        )
        record.pet = pet
        modelContext.insert(record)
        return record
    }

    @ViewBuilder
    private func cardView(record: CertificateRecord) -> some View {
        switch certType {
        case .pedigree: PedigreeCardView(record: record)
        case .beauty:   BeautyCardView(record: record)
        case .personality: PersonalityCardView(record: record)
        }
    }
}

enum InferencePhase: Equatable {
    case loading, success, fallback
}

#Preview {
    NavigationStack {
        AIInferenceView(
            pet: PetProfile(name: "橘猫小明", category: .cat, birthday: Date()),
            certType: .pedigree
        )
    }
}
