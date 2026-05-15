// PawStar/Models/PetProfile.swift
import Foundation
import SwiftData

@Model
final class PetProfile {
    @Attribute(.unique) var id: UUID
    var name: String
    var category: PetCategory
    var birthday: Date?
    var avatarImageData: Data?
    var wechatQRImageData: Data?
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \CertificateRecord.pet)
    var certificates: [CertificateRecord]

    init(
        id: UUID = UUID(),
        name: String,
        category: PetCategory,
        birthday: Date? = nil,
        avatarImageData: Data? = nil,
        wechatQRImageData: Data? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.birthday = birthday
        self.avatarImageData = avatarImageData
        self.wechatQRImageData = wechatQRImageData
        self.createdAt = createdAt
        self.certificates = []
    }
}

enum PetCategory: String, Codable, CaseIterable {
    case cat = "cat"
    case dog = "dog"

    var displayName: String {
        switch self {
        case .cat: return "猫"
        case .dog: return "狗"
        }
    }
}
