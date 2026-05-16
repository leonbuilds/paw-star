// PawStar/Services/FallbackProvider.swift
import Foundation

// 网络失败时的本地兜底数据
struct FallbackProvider {
    static func result(for type: CertificateType, category: PetCategory) -> AIResultPayload {
        switch type {
        case .pedigree:
            return AIResultPayload(
                primaryLabel: category == .cat ? "中华田园猫" : "中华田园犬",
                grade: "SR",
                attributes: ["coatColor": "灵动色系", "saturation": "88"],
                description: "鉴定系统暂时开小差了，但这只\(category == .cat ? "猫" : "狗")的气质告诉我们，它必定血统非凡。"
            )
        case .beauty:
            return AIResultPayload(
                primaryLabel: "工业糖精级",
                grade: "A+",
                attributes: ["颜值": "88", "萌度": "92", "气质": "85", "卖萌能力": "90", "治愈力": "95"],
                description: "网络开了个小差，但颜值这种东西，不需要 AI 来定义——它已经征服了你的眼睛。"
            )
        case .personality:
            return AIResultPayload(
                primaryLabel: "社恐型社牛",
                grade: "SR",
                attributes: ["trait1": "神秘感爆棚", "trait2": "看透人心", "trait3": "独立自主", "trait4": "偶尔粘人"],
                description: "鉴定系统离线了，但从它的眼神判断：这是一个外冷内热、懂得分寸的灵魂。"
            )
        }
    }
}
