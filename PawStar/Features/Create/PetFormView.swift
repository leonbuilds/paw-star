// PawStar/Features/Create/PetFormView.swift
import SwiftUI
import SwiftData

struct PetFormView: View {
    let avatarImage: UIImage
    let certType: CertificateType

    @Environment(\.modelContext) private var modelContext
    @State private var name: String = ""
    @State private var category: PetCategory = .cat
    @State private var hasBirthday = false
    @State private var birthday: Date = Date()
    @State private var isSaved = false

    var body: some View {
        VStack(spacing: 20) {
            avatarSection

            VStack(spacing: 16) {
                FormRow(label: "名字") {
                    TextField("给 TA 取个名字", text: $name)
                        .font(Theme.Font.body())
                }
                FormRow(label: "品类") {
                    Picker("品类", selection: $category) {
                        Text("🐱 猫").tag(PetCategory.cat)
                        Text("🐶 狗").tag(PetCategory.dog)
                    }
                    .pickerStyle(.segmented)
                }
                FormRow(label: "生日") {
                    Toggle("填写生日", isOn: $hasBirthday)
                        .tint(Theme.Color.primary)
                    if hasBirthday {
                        DatePicker("", selection: $birthday, in: ...Date(), displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .labelsHidden()
                    }
                }
            }
            .padding(16)
            .background(Theme.Color.cardWhite)
            .clipShape(RoundedRectangle(cornerRadius: 16))

            Spacer()

            NavigationLink(destination: Text("证件预览（Phase 3 实现）"), isActive: $isSaved) {
                EmptyView()
            }

            Button(action: save) {
                Text("生成证件 🐾")
                    .font(Theme.Font.cardTitle())
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(name.isEmpty ? Theme.Color.border : Theme.Color.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .disabled(name.isEmpty)
        }
        .padding(20)
        .background(Theme.Color.warmWhite)
        .navigationTitle("填写信息")
    }

    private var avatarSection: some View {
        Image(uiImage: avatarImage)
            .resizable().scaledToFill()
            .frame(width: 100, height: 100)
            .clipShape(Circle())
            .overlay(Circle().strokeBorder(Theme.Color.primary, lineWidth: 3))
    }

    private func save() {
        let pet = PetProfile(
            name: name,
            category: category,
            birthday: hasBirthday ? birthday : Date(),
            avatarImageData: avatarImage.jpegData(compressionQuality: 0.85)
        )
        modelContext.insert(pet)
        isSaved = true
    }
}

private struct FormRow<Content: View>: View {
    let label: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(Theme.Font.caption())
                .foregroundStyle(Theme.Color.textSecondary)
            content()
        }
    }
}

#Preview {
    NavigationStack {
        PetFormView(avatarImage: UIImage(), certType: .pedigree)
    }
}
