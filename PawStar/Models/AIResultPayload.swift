// PawStar/Models/AIResultPayload.swift
import Foundation

struct AIResultPayload: Codable {
    var primaryLabel: String
    var grade: String
    var attributes: [String: String]
    var description: String
}

extension AIResultPayload {
    static func sampleCat() -> AIResultPayload {
        AIResultPayload(
            primaryLabel: "橘猫",
            grade: "S",
            attributes: ["毛色": "橘色", "体型": "丰满", "性格": "粘人"],
            description: "典型橘猫，热爱美食，忠诚度极高。"
        )
    }
    static func sampleDog() -> AIResultPayload {
        AIResultPayload(
            primaryLabel: "柴犬",
            grade: "A+",
            attributes: ["毛色": "赤色", "体型": "中等", "性格": "独立"],
            description: "纯血柴犬，独立骄傲，是理想的家庭伴侣。"
        )
    }
    static func sampleRare() -> AIResultPayload {
        AIResultPayload(
            primaryLabel: "神秘猫咪",
            grade: "SSR",
            attributes: ["毛色": "渐变", "体型": "优雅", "性格": "神秘"],
            description: "极稀有品种，出现概率不足 0.1%。"
        )
    }
}
