// PawStar/Features/Cards/PersonalityCardView.swift
import SwiftUI

struct PersonalityCardView: View {
    let record: CertificateRecord
    private let gradient = [Color(hex: "#A78BFA"), Color(hex: "#818CF8")]

    var body: some View {
        VStack(spacing: 0) {
            CardBanner(title: "萌宠性格鉴定书", english: "PERSONALITY CERTIFICATE", gradient: gradient)

            VStack(spacing: 14) {
                CardAvatar(
                    name: record.pet?.name ?? "未知",
                    serialNumber: record.serialNumber,
                    avatarData: record.pet?.avatarImageData,
                    ringColor: Color(hex: "#A78BFA")
                )
                .offset(y: -12)
                .padding(.bottom, -12)

                CardDivider(color: Color(hex: "#A78BFA"))

                if let payload = record.payload {
                    // 性格类型 + 等级
                    HStack(alignment: .center) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("性格类型").font(.system(size: 10, weight: .medium)).foregroundStyle(Theme.Color.textSecondary)
                            Text(payload.primaryLabel)
                                .font(.system(size: 20, weight: .black, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(colors: gradient, startPoint: .leading, endPoint: .trailing)
                                )
                                .lineLimit(1).minimumScaleFactor(0.7)
                        }
                        Spacer()
                        GradeBadge(grade: payload.grade, color: Color(hex: "#A78BFA"))
                    }

                    // 特质标签 2×2 网格
                    let chips = Array(payload.attributes.values.prefix(4))
                    let rows = chips.isEmpty ? [["尚未发现", "神秘未知"], ["正在分析", "待定"]] :
                               [Array(chips.prefix(2)), Array(chips.dropFirst(2).prefix(2))]
                    VStack(spacing: 8) {
                        ForEach(0..<rows.count, id: \.self) { rowIdx in
                            HStack(spacing: 8) {
                                ForEach(rows[rowIdx], id: \.self) { chip in
                                    Text(chip)
                                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                                        .foregroundStyle(Color(hex: "#A78BFA"))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 10)
                                        .background(Color(hex: "#A78BFA").opacity(0.1))
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                        .overlay(RoundedRectangle(cornerRadius: 10)
                                            .strokeBorder(Color(hex: "#A78BFA").opacity(0.3), lineWidth: 1))
                                }
                            }
                        }
                    }

                    QuoteBox(text: payload.description, accent: Color(hex: "#A78BFA"))
                }

                Spacer(minLength: 0)
                CardFooter()
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
            .padding(.top, 8)
        }
        .frame(width: 350, height: 622)
        .background(Theme.Color.cardWhite)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: Color(hex: "#A78BFA").opacity(0.2), radius: 20, x: 0, y: 8)
    }

    func render() -> UIImage {
        let renderer = ImageRenderer(content: self.frame(width: 350, height: 622))
        renderer.scale = 3
        return renderer.uiImage ?? UIImage()
    }
}

#Preview {
    ScrollView {
        PersonalityCardView(record: {
            var p = AIResultPayload.sampleDog()
            p.primaryLabel = "社恐型社牛"
            p.grade = "SSR"
            p.attributes = ["trait1": "独立自主", "trait2": "外冷内热", "trait3": "看透人心", "trait4": "偶尔粘人"]
            p.description = "表面一副「我不需要你」的高冷态度，实际上已经默默记住了你每天回家的时间。"
            let data = (try? JSONEncoder().encode(p)) ?? Data()
            return CertificateRecord(type: .personality, serialNumber: "PP-2026-0517-A3D9E1-7C", aiResultData: data)
        }()).padding(20)
    }.background(Theme.Color.warmWhite)
}
