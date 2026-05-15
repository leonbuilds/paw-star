// PawStar/Features/Cards/PedigreeCardView.swift
import SwiftUI

struct PedigreeCardView: View {
    let record: CertificateRecord

    var body: some View {
        VStack(spacing: 16) {
            CardHeader(title: "萌宠品相鉴定书", english: "PawPedigree Certificate")
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
                    Text(payload.primaryLabel).font(Theme.Font.title(24)).foregroundStyle(Theme.Color.primary)
                    Spacer()
                    GradeTag(grade: payload.grade)
                }
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(payload.attributes.sorted(by: { $0.key < $1.key }), id: \.key) { k, v in
                        HStack {
                            Text(k).font(Theme.Font.caption()).foregroundStyle(Theme.Color.textSecondary)
                            Spacer()
                            Text(v).font(Theme.Font.caption()).foregroundStyle(Theme.Color.textPrimary)
                        }
                    }
                }
                Text(payload.description).font(Theme.Font.body(14)).foregroundStyle(Theme.Color.textSecondary).lineLimit(3)
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
    PedigreeCardView(record: {
        let payload = AIResultPayload.sampleCat()
        let data = (try? JSONEncoder().encode(payload)) ?? Data()
        return CertificateRecord(type: .pedigree, serialNumber: SerialNumberGenerator.generate(), aiResultData: data)
    }()).padding(20).background(Theme.Color.warmWhite)
}
