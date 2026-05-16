// PawStar/Services/NetworkService.swift
import Foundation

enum NetworkError: Error {
    case invalidURL, timeout, upstream, decode
}

struct CertifyRequest: Encodable {
    let type: String
    let image: String       // base64
    let petCategory: String
}

final class NetworkService {
    static let shared = NetworkService()
    private init() {}

    private var baseURL: String {
        Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String
        ?? "https://pawpedigree-api.workers.dev"
    }

    func certify(type: CertificateType, imageData: Data, category: PetCategory) async throws -> AIResultPayload {
        guard let url = URL(string: baseURL) else { throw NetworkError.invalidURL }

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.timeoutInterval = 8

        let body = CertifyRequest(
            type: type.rawValue,
            image: imageData.base64EncodedString(),
            petCategory: category.rawValue
        )
        req.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: req)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw NetworkError.upstream
        }

        do {
            return try JSONDecoder().decode(AIResultPayload.self, from: data)
        } catch {
            throw NetworkError.decode
        }
    }
}
