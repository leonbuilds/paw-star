// PawStar/Features/Cards/PedigreeCardView.swift
import SwiftUI

struct PedigreeCardView: View {
    let record: CertificateRecord

    private let gradient = [Theme.Color.primary, Theme.Color.certGold]

    var body: some View {
        VStack(spacing: 0) {
            // 渐变头部
            CardBanner(title: "萌宠品相鉴定书", english: "PAW PEDIGREE CERTIFICATE", gradient: gradient)

            VStack(spacing: 14) {
                // 头像区
                CardAvatar(
                    name: record.pet?.name ?? "未知",
                    serialNumber: record.serialNumber,
                    avatarData: record.pet?.avatarImageData,
                    ringColor: Theme.Color.primary
                )
                .offset(y: -12)
                .padding(.bottom, -12)

                CardDivider(color: Theme.Color.certGold)

                if let payload = record.payload {
                    // 品种 + 等级
                    HStack(alignment: .center) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("品种鉴定")
                                .font(.system(size: 10, weight: .medium)).foregroundStyle(Theme.Color.textSecondary)
                            Text(payload.primaryLabel)
                                .font(.system(size: 22, weight: .black, design: .rounded))
                                .foregroundStyle(Theme.Color.primary)
                        }
                        Spacer()
                        GradeBadge(grade: payload.grade, color: Theme.Color.certGold)
                    }

                    // 属性列表
                    VStack(spacing: 8) {
                        ForEach(payload.attributes.sorted(by: { $0.key < $1.key }), id: \.key) { k, v in
                            AttrRow(key: k, value: v, accent: Theme.Color.primary)
                        }
                    }
                    .padding(12)
                    .background(Theme.Color.warmWhite)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    // 描述
                    QuoteBox(text: payload.description, accent: Theme.Color.primary)
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
        .shadow(color: Theme.Color.primary.opacity(0.15), radius: 20, x: 0, y: 8)
    }

    func render() -> UIImage {
        let renderer = ImageRenderer(content: self.frame(width: 350, height: 622))
        renderer.scale = 3
        return renderer.uiImage ?? UIImage()
    }
}

#Preview {
    ScrollView {
        PedigreeCardView(record: {
            var p = AIResultPayload.sampleCat()
            p.primaryLabel = "橘猫（赤金系）"
            p.grade = "SR"
            p.attributes = ["毛色": "橘黄", "饱和度": "88", "体型": "丰满圆润"]
            p.description = "此猫眉眼带星，骨相端正，是难得一见的「村霸气质+御猫风骨」复合品相，四肢短而有力，是天生的沙发霸主。"
            let data = (try? JSONEncoder().encode(p)) ?? Data()
            return CertificateRecord(type: .pedigree, serialNumber: "PP-2026-0517-7E3A2B-9F", aiResultData: data)
        }()).padding(20)
    }.background(Theme.Color.warmWhite)
}
