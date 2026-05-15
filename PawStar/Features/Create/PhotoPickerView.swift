// PawStar/Features/Create/PhotoPickerView.swift
import SwiftUI
import PhotosUI

struct PhotoPickerView: View {
    let certType: CertificateType
    @State private var selectedItem: PhotosPickerItem?
    @State private var croppedImage: UIImage?
    @State private var isProcessing = false

    var body: some View {
        VStack(spacing: 24) {
            Text("选一张最好看的照片")
                .font(Theme.Font.title())
                .foregroundStyle(Theme.Color.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            photoPreview
            PhotosPicker(selection: $selectedItem, matching: .images) {
                Label("选择照片", systemImage: "photo.on.rectangle")
                    .font(Theme.Font.body())
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Theme.Color.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            NavigationLink(destination: PetFormView(avatarImage: croppedImage ?? UIImage(), certType: certType)) {
                Text("下一步")
                    .font(Theme.Font.body())
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(croppedImage != nil ? Theme.Color.primaryDark : Theme.Color.border)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .disabled(croppedImage == nil)
            Spacer()
        }
        .padding(20)
        .background(Theme.Color.warmWhite)
        .navigationTitle(certType.displayName)
        .onChange(of: selectedItem) { _, newItem in
            Task {
                isProcessing = true
                defer { isProcessing = false }
                guard let data = try? await newItem?.loadTransferable(type: Data.self),
                      let uiImage = UIImage(data: data) else { return }
                croppedImage = await ImageProcessor.squareCrop(uiImage)
            }
        }
    }

    @ViewBuilder
    private var photoPreview: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(croppedImage != nil ? Theme.Color.primary : Theme.Color.border,
                              style: StrokeStyle(lineWidth: 2, dash: croppedImage != nil ? [] : [8]))
                .frame(width: 200, height: 200)
            if let img = croppedImage {
                Image(uiImage: img).resizable().scaledToFill()
                    .frame(width: 200, height: 200).clipShape(RoundedRectangle(cornerRadius: 20))
            } else if isProcessing {
                ProgressView().tint(Theme.Color.primary)
            } else {
                Image(systemName: "camera.fill").font(.system(size: 40)).foregroundStyle(Theme.Color.border)
            }
        }
    }
}

#Preview { NavigationStack { PhotoPickerView(certType: .pedigree) } }
