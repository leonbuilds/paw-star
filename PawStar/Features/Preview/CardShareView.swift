// PawStar/Features/Preview/CardShareView.swift
import SwiftUI
import Photos

struct CardShareView<Card: View>: View {
    let card: Card
    let renderImage: () -> UIImage

    @State private var shareImage: UIImage?
    @State private var showShare = false
    @State private var saveToast = ""
    @State private var showToast = false
    @State private var isRendering = false

    var body: some View {
        ZStack {
            Theme.Color.warmWhite.ignoresSafeArea()
            VStack(spacing: 0) {
                ScrollView {
                    card
                        .padding(20)
                        .padding(.bottom, 100)
                }
                Spacer(minLength: 0)
            }

            // 底部操作栏
            VStack {
                Spacer()
                HStack(spacing: 12) {
                    // 保存到相册
                    Button {
                        saveToAlbum()
                    } label: {
                        Label("保存相册", systemImage: "arrow.down.to.line")
                            .font(Theme.Font.body())
                            .foregroundStyle(Theme.Color.primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Theme.Color.primary.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }

                    // 分享
                    Button {
                        Task { await share() }
                    } label: {
                        Label(isRendering ? "生成中…" : "分享", systemImage: "square.and.arrow.up")
                            .font(Theme.Font.body())
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(isRendering ? Theme.Color.border : Theme.Color.primary)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .disabled(isRendering)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
                .background(
                    Theme.Color.warmWhite
                        .shadow(color: .black.opacity(0.06), radius: 8, y: -4)
                )
            }

            // 保存成功 Toast
            if showToast {
                VStack {
                    Spacer()
                    Text(saveToast)
                        .font(Theme.Font.body())
                        .foregroundStyle(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.black.opacity(0.75))
                        .clipShape(Capsule())
                        .padding(.bottom, 120)
                }
                .transition(.opacity)
            }
        }
        .sheet(isPresented: $showShare) {
            if let img = shareImage {
                ShareSheet(items: [img])
            }
        }
    }

    @MainActor
    private func share() async {
        isRendering = true
        let img = renderImage()
        shareImage = img
        isRendering = false
        showShare = true
    }

    private func saveToAlbum() {
        let img = renderImage()
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            DispatchQueue.main.async {
                if status == .authorized || status == .limited {
                    UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil)
                    saveToast = "已保存到相册 ✓"
                } else {
                    saveToast = "请在设置中允许访问相册"
                }
                withAnimation { showToast = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation { showToast = false }
                }
            }
        }
    }
}

// UIActivityViewController 包装
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let vc = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return vc
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
