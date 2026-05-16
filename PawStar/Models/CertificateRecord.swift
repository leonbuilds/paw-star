// PawStar/Models/CertificateRecord.swift
import Foundation
import SwiftData

@Model
final class CertificateRecord {
    @Attribute(.unique) var id: UUID
    var type: CertificateType
    var serialNumber: String
    // AIResultPayload 序列化存储（SwiftData 不支持嵌套 Codable struct 直接持久化）
    var aiResultData: Data
    var renderedImageData: Data?
    var includesWechatQR: Bool
    var createdAt: Date

    var pet: PetProfile?

    init(
        id: UUID = UUID(),
        type: CertificateType,
        serialNumber: String,
        aiResultData: Data,
        renderedImageData: Data? = nil,
        includesWechatQR: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.type = type
        self.serialNumber = serialNumber
        self.aiResultData = aiResultData
        self.renderedImageData = renderedImageData
        self.includesWechatQR = includesWechatQR
        self.createdAt = createdAt
    }

    var payload: AIResultPayload? {
        try? JSONDecoder().decode(AIResultPayload.self, from: aiResultData)
    }
}

enum CertificateType: String, Codable, CaseIterable {
    case pedigree = "pedigree"
    case beauty = "beauty"
    case personality = "personality"

    var displayName: String {
        switch self {
        case .pedigree: return "血统鉴定书"
        case .beauty: return "颜值鉴定书"
        case .personality: return "性格画像证"
        }
    }
}
