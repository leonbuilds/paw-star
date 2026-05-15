// PawStar/Services/ImageProcessor.swift
import UIKit

enum ImageProcessor {
    static func squareCrop(_ image: UIImage) async -> UIImage {
        let size = min(image.size.width, image.size.height)
        let origin = CGPoint(x: (image.size.width - size) / 2, y: (image.size.height - size) / 2)
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: size, height: size))
        return renderer.image { _ in image.draw(at: CGPoint(x: -origin.x, y: -origin.y)) }
    }

    static func resize(_ image: UIImage, maxEdge: CGFloat = 1024) -> UIImage {
        let scale = min(maxEdge / image.size.width, maxEdge / image.size.height, 1)
        let newSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in image.draw(in: CGRect(origin: .zero, size: newSize)) }
    }

    static func processForUpload(_ image: UIImage) async -> Data? {
        let cropped = await squareCrop(image)
        let resized = resize(cropped)
        return resized.jpegData(compressionQuality: 0.85)
    }
}
