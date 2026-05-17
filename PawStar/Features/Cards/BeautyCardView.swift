// PawStar/Features/Cards/BeautyCardView.swift
import SwiftUI

struct BeautyCardView: View {
    let record: CertificateRecord
    private let scoreKeys = ["颜值", "萌度", "气质", "卖萌能力", "治愈力"]
    private let gradient = [Theme.Color.sakuraPink, Color(hex: "#FF6B9D")]

    var body: some View {
        VStack(spacing: 0) {
            CardBanner(title: "萌宠颜值鉴定书", english: "BEAUTY CERTIFICATE", gradient: gradient)

            VStack(spacing: 14) {
                CardAvatar(
                    name: record.pet?.name ?? "未知",
                    serialNumber: record.serialNumber,
                    avatarData: record.pet?.avatarImageData,
                    ringColor: Theme.Color.sakuraPink
                )
                .offset(y: -12)
                .padding(.bottom, -12)

                CardDivider(color: Theme.Color.sakuraPink)

                if let payload = record.payload {
                    // 大分数 + 等级
                    HStack(alignment: .center, spacing: 16) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("综合颜值").font(.system(size: 10, weight: .medium)).foregroundStyle(Theme.Color.textSecondary)
                            HStack(alignment: .lastTextBaseline, spacing: 4) {
                                Text(payload.grade)
                                    .font(.system(size: 40, weight: .black, design: .rounded))
                                    .foregroundStyle(
                                        LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
                                    )
                                Text("级").font(.system(size: 14, weight: .medium)).foregroundStyle(Theme.Color.textSecondary)
                            }
                        }
                        Spacer()
                        // 五角星装饰
                        VStack(spacing: 2) {
                            Text("✨✨✨").font(.system(size: 16))
                            Text(payload.primaryLabel)
                                .font(.system(size: 11, weight: .semibold, design: .rounded))
                                .foregroundStyle(Theme.Color.sakuraPink)
                                .multilineTextAlignment(.center)
                        }
                    }

                    // 评分条
                    VStack(spacing: 9) {
                        ForEach(scoreKeys, id: \.self) { key in
                            let val = Double(payload.attributes[key] ?? "70") ?? 70
                            HStack(spacing: 8) {
                                Text(key)
                                    .font(.system(size: 11, weight: .medium, design: .rounded))
                                    .foregroundStyle(Theme.Color.textSecondary)
                                    .frame(width: 52, alignment: .leading)
                                GeometryReader { geo in
                                    ZStack(alignment: .leading) {
                                        Capsule().fill(Theme.Color.border).frame(height: 8)
                                        Capsule()
                                            .fill(LinearGradient(colors: [Theme.Color.sakuraPink, Color(hex: "#FF6B9D")],
                                                                 startPoint: .leading, endPoint: .trailing))
                                            .frame(width: max(8, geo.size.width * val / 100), height: 8)
                                    }
                                }.frame(height: 8)
                                Text("\(Int(val))")
                                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                                    .foregroundStyle(Theme.Color.sakuraPink)
                                    .frame(width: 26, alignment: .trailing)
                            }
                        }
                    }
                    .padding(12)
                    .background(Theme.Color.warmWhite)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    QuoteBox(text: payload.description, accent: Theme.Color.sakuraPink)
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
        .shadow(color: Theme.Color.sakuraPink.opacity(0.2), radius: 20, x: 0, y: 8)
    }

    func render() -> UIImage {
        let renderer = ImageRenderer(content: self.frame(width: 350, height: 622))
        renderer.scale = 3
        return renderer.uiImage ?? UIImage()
    }
}

#Preview {
    ScrollView {
        BeautyCardView(record: {
            var p = AIResultPayload.sampleCat()
            p.primaryLabel = "工业糖精级"
            p.grade = "S+"
            p.attributes = ["颜值": "92", "萌度": "88", "气质": "76", "卖萌能力": "95", "治愈力": "90"]
            p.description = "五官比例精准，毛发光泽度超标，属于工业糖精级别——看一眼就停不下来。"
            let data = (try? JSONEncoder().encode(p)) ?? Data()
            return CertificateRecord(type: .beauty, serialNumber: "PP-2026-0517-8F2C1A-3D", aiResultData: data)
        }()).padding(20)
    }.background(Theme.Color.warmWhite)
}
