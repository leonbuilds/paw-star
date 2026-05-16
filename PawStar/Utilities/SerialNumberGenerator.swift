// PawStar/Utilities/SerialNumberGenerator.swift
import Foundation

enum SerialNumberGenerator {
    // 格式：PP-YYYY-MMDD-XXXXXX-XX（娱乐用，非真实证件号）
    static func generate() -> String {
        let calendar = Calendar.current
        let now = Date()
        let year = calendar.component(.year, from: now)
        let month = String(format: "%02d", calendar.component(.month, from: now))
        let day = String(format: "%02d", calendar.component(.day, from: now))
        let hex6 = String(format: "%06X", Int.random(in: 0..<0xFFFFFF))
        let hex2 = String(format: "%02X", Int.random(in: 0..<0xFF))
        return "PP-\(year)-\(month)\(day)-\(hex6)-\(hex2)"
    }
}
