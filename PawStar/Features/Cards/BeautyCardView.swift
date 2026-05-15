// PawStar/Features/Cards/BeautyCardView.swift
import SwiftUI

struct BeautyCardView: View {
    let record: CertificateRecord
    private let scoreKeys = ["颜值", "萌度", "气质", "卖萌能力", "治愈力"]

    var body: some View {
        VStack(spacing: 16) {
            CardHeader(title: "萌宠颜值鉴定书", english: "Beauty Certificate")
            CardPhotoSection(petName: record.pet?.name ?? "未知", serialNumber: record.serialNumber, avatarData: record.pet?.avatarImageData)
            CardDivider()
            mainSection
            Spacer(minLength: 0)
            CardFooter()
        }
        .padding(20)
        .frame(width: 350, height: 622)
        .background(Theme.Color.cardWhite)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.12), radius: 16, x: 0, y: 8)
    }

    private var mainSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let payload = record.payload {
                HStack(alignment: .lastTextBaseline, spacing: 8) {
                    Text(payload.grade).font(Theme.Font.title(32)).foregroundStyle(Theme.Color.sakuraPink)
                    Text("颜值等级").font(Theme.Font.caption()).foregroundStyle(Theme.Color.textSecondary)
                }
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(scoreKeys, id: \.self) { key in
                        let val = Double(payload.attributes[key] ?? "70") ?? 70
                        HStack(spacing: 8) {
                            Text(key).font(Theme.Font.caption(11)).foregroundStyle(Theme.Color.textSecondary).frame(width: 56, alignment: .leading)
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    Capsule().fill(Theme.Color.border).frame(height: 6)
                                    Capsule().fill(Theme.Color.sakuraPink).frame(width: geo.size.width * val / 100, height: 6)
                                }
                            }.frame(height: 6)
                            Text("\(Int(val))").font(Theme.Font.caption(11)).foregroundStyle(Theme.Color.textSecondary).frame(width: 28, alignment: .trailing)
                        }
                    }
                }
                Text(payload.description).font(Theme.Font.body(13)).foregroundStyle(Theme.Color.textSecondary).lineLimit(2)
            }
        }
    }

    func render() -> UIImage {
        let renderer = ImageRenderer(content: self.frame(width: 350, height: 622))
        renderer.scale = 3
        return renderer.uiImage ?? UIImage()
    }
}

#Preview {
    BeautyCardView(record: {
        var payload = AIResultPayload.sampleCat()
        payload.grade = "S+"
        payload.attributes = ["颜值": "92", "萌度": "88", "气质": "76", "卖萌能力": "95", "治愈力": "90"]
        let data = (try? JSONEncoder().encode(payload)) ?? Data()
        return CertificateRecord(type: .beauty, serialNumber: SerialNumberGenerator.generate(), aiResultData: data)
    }()).padding(20).background(Theme.Color.warmWhite)
}
