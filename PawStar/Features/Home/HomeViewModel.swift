// PawStar/Features/Home/HomeViewModel.swift
import Foundation
import Observation

@Observable
final class HomeViewModel {
    var greeting: String = "你好，铲屎官 👋"
    var recentRecords: [CertificateRecord] = []
    var isLoading: Bool = false
}
