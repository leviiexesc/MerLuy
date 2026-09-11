import PhotosUI
import SwiftUI
import UIKit

struct ProfileView: View {
    @EnvironmentObject private var profile: UserProfile
    @EnvironmentObject private var language: LanguageManager
    @State private var showingAuth = false
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var licenseKey = ""
    @State private var licenseMessage: String?

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                header
                if profile.isLoggedIn {
                    profileCard
                    verificationCard
                    planCard
                    licenseCard
                    Button {
                        profile.logOut()
                    } label: {
                        Label("Log Out", systemImage: "rectangle.portrait.and.arrow.right")
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: 50)
                    }
                    .foregroundStyle(MerLuyTheme.negative)
                    .background(MerLuyTheme.negative.opacity(0.10))
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                } else {
                    loggedOutCard
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
        }
        .sheet(isPresented: $showingAuth) {
            ProfileAuthView()
        }
        .onChange(of: selectedPhoto) { item in
            Task {
                guard let data = try? await item?.loadTransferable(type: Data.self) else { return }
                profile.imageData = data
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Profile").font(.system(size: 26, weight: .bold, design: .rounded))
            Text("Your account, verification, and plan")
                .font(.system(size: 13)).foregroundStyle(MerLuyTheme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var profileCard: some View {
        VStack(spacing: 14) {
            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                ProfileAvatar(data: profile.imageData, size: 88)
                    .overlay(alignment: .bottomTrailing) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 30, height: 30)
                            .background(MerLuyTheme.indigo)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(MerLuyTheme.background, lineWidth: 3))
                    }
            }
            .frame(minWidth: 100, minHeight: 100)
            Text(profile.name).font(.system(size: 20, weight: .bold, design: .rounded))
            Text(profile.email).font(.system(size: 12)).foregroundStyle(MerLuyTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .glassCard(radius: 20)
    }

    private var verificationCard: some View {
        HStack(spacing: 12) {
            Image(systemName: profile.isVerified ? "checkmark.seal.fill" : "exclamationmark.circle.fill")
                .font(.system(size: 22)).foregroundStyle(profile.isVerified ? MerLuyTheme.positive : .orange)
            VStack(alignment: .leading, spacing: 4) {
                Text(profile.isVerified ? "Account Verified" : "Verify your account").font(.system(size: 14, weight: .bold))
                Text(profile.isVerified ? "Your profile is ready to use." : "Tap verify to complete your demo profile.")
                    .font(.system(size: 11)).foregroundStyle(MerLuyTheme.textSecondary)
            }
            Spacer()
            if !profile.isVerified {
                Button("Verify") { profile.verify() }
                    .font(.system(size: 12, weight: .bold))
                    .padding(.horizontal, 12).frame(minHeight: 40)
                    .background(MerLuyTheme.indigo).foregroundStyle(.white).clipShape(Capsule())
            }
        }
        .padding(15).glassCard(radius: 17)
    }

    private var planCard: some View {
        HStack(spacing: 12) {
            Image(systemName: profile.isPro ? "crown.fill" : "sparkles")
                .foregroundStyle(profile.isPro ? .yellow : MerLuyTheme.indigo)
                .frame(width: 40, height: 40).background(Color.white.opacity(0.08)).clipShape(RoundedRectangle(cornerRadius: 12))
            VStack(alignment: .leading, spacing: 4) {
                Text(profile.isPro ? "Pro Plan" : "Free Plan").font(.system(size: 14, weight: .bold))
                Text(profile.isPro ? "Premium features are active" : "Contact the owner for a license key")
                    .font(.system(size: 11)).foregroundStyle(MerLuyTheme.textSecondary)
            }
            Spacer()
            Text(profile.isPro ? "ACTIVE" : "FREE").font(.system(size: 10, weight: .bold)).foregroundStyle(profile.isPro ? MerLuyTheme.positive : MerLuyTheme.textSecondary)
        }
        .padding(15).glassCard(radius: 17)
    }

    private var licenseCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Pro license").font(.system(size: 14, weight: .bold))
            Text("Enter a license key provided by the owner to activate Pro on this device.")
                .font(.system(size: 11)).foregroundStyle(MerLuyTheme.textSecondary)
            TextField("License key", text: $licenseKey)
                .textInputAutocapitalization(.characters)
                .autocorrectionDisabled()
                .font(.system(size: 13, weight: .medium, design: .monospaced))
                .padding(.horizontal, 13)
                .frame(minHeight: 48)
                .background(Color.white.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 13))
            Button("Activate Pro") { activatePro() }
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(minHeight: 48)
                .background(MerLuyTheme.indigo)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            if let licenseMessage {
                Text(licenseMessage)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(profile.isPro ? MerLuyTheme.positive : MerLuyTheme.negative)
            }
        }
        .padding(15)
        .glassCard(radius: 17)
    }

    private var loggedOutCard: some View {
        VStack(spacing: 15) {
            ProfileAvatar(data: nil, size: 76)
            Text("Create your MerLuy profile").font(.system(size: 18, weight: .bold))
            Text("Save your name, verification, profile image, and Pro status on this device.")
                .multilineTextAlignment(.center).font(.system(size: 12)).foregroundStyle(MerLuyTheme.textSecondary)
            Button("Login / Register") { showingAuth = true }
                .font(.system(size: 14, weight: .bold)).foregroundStyle(.white)
                .frame(maxWidth: .infinity).frame(minHeight: 50)
                .background(MerLuyTheme.indigo).clipShape(RoundedRectangle(cornerRadius: 15))
        }
        .padding(20).glassCard(radius: 20)
    }
}

struct ProfileAvatar: View {
    let data: Data?
    let size: CGFloat
    var body: some View {
        Group {
            if let data, let image = UIImage(data: data) {
                Image(uiImage: image).resizable().scaledToFill()
            } else {
                Image(systemName: "person.fill").font(.system(size: size * 0.42)).foregroundStyle(.white)
                    .frame(width: size, height: size).background(LinearGradient(colors: [Color.cyan, MerLuyTheme.indigo], startPoint: .topLeading, endPoint: .bottomTrailing))
            }
        }
        .frame(width: size, height: size).clipShape(Circle())
    }
}

private struct ProfileAuthView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var profile: UserProfile
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var error: String?

    var body: some View {
        NavigationStack {
            ZStack { AppBackground(); VStack(spacing: 14) {
                Text("Login / Register").font(.system(size: 25, weight: .bold, design: .rounded))
                TextField("Your name", text: $name).authStyle()
                TextField("Email", text: $email).textInputAutocapitalization(.never).keyboardType(.emailAddress).authStyle()
                SecureField("Password", text: $password).authStyle()
                if let error { Text(error).font(.system(size: 12)).foregroundStyle(MerLuyTheme.negative) }
                Button("Continue") {
                    guard email.contains("@"), password.count >= 6 else { error = "Enter a valid email and 6+ character password."; return }
                    if email.caseInsensitiveCompare("admin@gmail.com") == .orderedSame {
                        guard profile.login(name: name, email: email, password: password) else { error = "Admin credentials are not valid."; return }
                    } else {
                        guard !name.isEmpty else { error = "Enter your name to create a User account."; return }
                        profile.register(name: name, email: email)
                    }
                    dismiss()
                }.font(.system(size: 15, weight: .bold)).foregroundStyle(.white).frame(maxWidth: .infinity).frame(minHeight: 50).background(MerLuyTheme.indigo).clipShape(RoundedRectangle(cornerRadius: 15))
            }.padding(20).glassCard(radius: 22).padding(18) }
            .toolbar { ToolbarItem(placement: .topBarLeading) { Button("Close") { dismiss() } } }
        }.preferredColorScheme(.dark)
    }
}

private extension ProfileView {
    func activatePro() {
        let normalizedKey = licenseKey.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        let testKeys = (1...10).map { String(format: "MERLUY-PRO-%03d", $0) } + ["MERLUY-PRO-BETA"]
        guard testKeys.contains(normalizedKey) else {
            licenseMessage = "Contact the owner for a valid license key."
            return
        }
        UserDefaults.standard.set(true, forKey: "merluy.proActivated")
        profile.isPro = true
        licenseMessage = "Pro activated on this device."
    }
}

private extension View {
    func authStyle() -> some View { self.font(.system(size: 14)).padding(.horizontal, 14).frame(minHeight: 50).background(Color.white.opacity(0.08)).clipShape(RoundedRectangle(cornerRadius: 14)) }
}
