// PawStar/Features/Cards/PersonalityCardView.swift
import SwiftUI

struct PersonalityCardView: View {
    let record: CertificateRecord

    var body: some View {
        VStack(spacing: 16) {
            CardHeader(title: "萌宠性格鉴定书", english: "Personality Certificate")
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
                HStack {
                    Text(payload.primaryLabel).font(Theme.Font.title(22)).foregroundStyle(Theme.Color.textPrimary)
                    Spacer()
                    GradeTag(grade: payload.grade)
                }
                let chips = Array(payload.attributes.values.prefix(4))
                HStack(spacing: 8) {
                    ForEach(chips, id: \.self) { chip in
                        Text(chip)
                            .font(Theme.Font.caption(12)).foregroundStyle(Theme.Color.primary)
                            .padding(.horizontal, 12).padding(.vertical, 5)
                            .background(Theme.Color.primary.opacity(0.1)).clipShape(Capsule())
                    }
                }
                Text(payload.description).font(Theme.Font.body(14)).foregroundStyle(Theme.Color.textSecondary).lineSpacing(4)
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
    PersonalityCardView(record: {
        var payload = AIResultPayload.sampleDog()
        payload.attributes = ["独立": "★★★★", "活泼": "★★★", "忠诚": "★★★★★", "聪明": "★★★★"]
        let data = (try? JSONEncoder().encode(payload)) ?? Data()
        return CertificateRecord(type: .personality, serialNumber: SerialNumberGenerator.generate(), aiResultData: data)
    }()).padding(20).background(Theme.Color.warmWhite)
}
