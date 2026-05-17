// PawStar/Services/NetworkService.swift
import Foundation

enum NetworkError: Error {
    case invalidURL, upstream, decode
}

final class NetworkService {
    static let shared = NetworkService()
    private init() {}

    private let endpoint = "https://dashscope.aliyuncs.com/api/v1/services/aigc/multimodal-generation/generation"
    private let apiKey = "sk-9c8b71c51ee44048816705f00e017b36"

    func certify(type: CertificateType, imageData: Data, category: PetCategory) async throws -> AIResultPayload {
        guard let url = URL(string: endpoint) else { throw NetworkError.invalidURL }

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.timeoutInterval = 30

        let b64 = imageData.base64EncodedString()
        let prompt = buildPrompt(type: type, category: category)

        let body: [String: Any] = [
            "model": "qwen-vl-plus",
            "input": [
                "messages": [[
                    "role": "user",
                    "content": [
                        ["image": "data:image/jpeg;base64,\(b64)"],
                        ["text": prompt]
                    ]
                ]]
            ],
            "parameters": ["result_format": "message"]
        ]

        req.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: req)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw NetworkError.upstream
        }

        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let text = (((json?["output"] as? [String: Any])?["choices"] as? [[String: Any]])?
            .first?["message"] as? [String: Any])?["content"] as? [[String: Any]],
              let raw = text.first?["text"] as? String else {
            throw NetworkError.decode
        }

        guard let match = raw.range(of: #"\{[\s\S]*\}"#, options: .regularExpression),
              let payload = try? JSONDecoder().decode(AIResultPayload.self, from: Data(raw[match].utf8)) else {
            throw NetworkError.decode
        }
        return payload
    }

    private func buildPrompt(type: CertificateType, category: PetCategory) -> String {
        let animal = category == .cat ? "猫" : "狗"
        let fallback: String
        switch type {
        case .pedigree:
            fallback = #"{"primaryLabel":"神秘血统","grade":"SSR","attributes":{"毛色":"灵动光泽","饱和度":"100"},"description":"自带神秘东方血脉，识别系统都无法定义其独特之美。"}"#
            return """
你是「PawPedigree 萌宠品相鉴定馆」的资深鉴定师。分析这张\(animal)的照片，输出娱乐性的"血统鉴定"。
只输出 JSON，不要任何前后缀：
{"primaryLabel":"<品种名>","grade":"<SSR|SR|R|N>","attributes":{"毛色":"<毛色描述>","饱和度":"<0-100>"},"description":"<30-100字反差/惊喜风格点评>"}
风格示例："此猫眉眼带星，是「村霸气质+御猫风骨」复合品相。"
识别困难时输出：\(fallback)
"""
        case .beauty:
            fallback = #"{"primaryLabel":"绝世容颜","grade":"S+","attributes":{"颜值":"99","萌度":"99","气质":"99","卖萌能力":"99","治愈力":"99"},"description":"颜值已超出鉴定系统量程，无法用数字定义此等美貌。"}"#
            return """
你是「PawPedigree 萌宠颜值鉴定馆」的评委。对这张\(animal)照片进行颜值鉴定。
只输出 JSON：
{"primaryLabel":"<颜值定性标签>","grade":"<S+|S|A+|A|B>","attributes":{"颜值":"<0-100>","萌度":"<0-100>","气质":"<0-100>","卖萌能力":"<0-100>","治愈力":"<0-100>"},"description":"<30-100字反差幽默点评>"}
识别困难时输出：\(fallback)
"""
        case .personality:
            fallback = #"{"primaryLabel":"谜之人格","grade":"SSR","attributes":{"特质1":"神秘感爆棚","特质2":"看透人心","特质3":"独立自主","特质4":"偶尔粘人"},"description":"自带神秘东方血脉，识别系统都无法定义其独特之美。"}"#
            return """
你是「PawPedigree 萌宠性格鉴定所」的心理咨询师。通过照片气质推断这只\(animal)的性格。
只输出 JSON：
{"primaryLabel":"<MBTI风格性格类型>","grade":"<SSR|SR|R>","attributes":{"特质1":"<标签>","特质2":"<标签>","特质3":"<标签>","特质4":"<标签>"},"description":"<30-100字走心性格分析>"}
识别困难时输出：\(fallback)
"""
        }
    }
}
