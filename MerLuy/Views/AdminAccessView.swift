import SwiftUI

struct AdminAccessView: View {
    @Binding var isAuthenticated: Bool
    @Environment(\.dismiss) private var dismiss
    @State private var isRegistering = false
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()
                VStack(spacing: 22) {
                    ZStack {
                        Circle().fill(LinearGradient(colors: [Color.cyan, MerLuyTheme.indigo], startPoint: .topLeading, endPoint: .bottomTrailing))
                        Image(systemName: "person.badge.key.fill")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    .frame(width: 72, height: 72)

                    VStack(spacing: 6) {
                        Text(isRegistering ? "Create Admin Account" : "Admin Login")
                            .font(.system(size: 25, weight: .bold, design: .rounded))
                        Text("Demo admin access for MerLuy")
                            .font(.system(size: 13))
                            .foregroundStyle(MerLuyTheme.textSecondary)
                    }

                    VStack(spacing: 12) {
                        AuthField(icon: "envelope", placeholder: "Admin email", text: $email)
                        AuthField(icon: "lock", placeholder: "Password", text: $password, isSecure: true)
                    }

                    if let errorMessage {
                        Text(errorMessage)
                            .font(.system(size: 12))
                            .foregroundStyle(MerLuyTheme.negative)
                    }

                    Button { authenticate() } label: {
                        Text(isRegistering ? "Register Admin" : "Login")
                            .font(.system(size: 15, weight: .bold))
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: 50)
                    }
                    .foregroundStyle(.white)
                    .background(MerLuyTheme.indigo)
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                    Button(isRegistering ? "Already have an account? Login" : "Create admin account") {
                        withAnimation(.easeInOut(duration: 0.2)) { isRegistering.toggle() }
                    }
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.cyan)

                    Text("Demo only: use any valid email and a password with at least 6 characters. Use a secure backend before production.")
                        .multilineTextAlignment(.center)
                        .font(.system(size: 11))
                        .foregroundStyle(MerLuyTheme.textSecondary)
                }
                .padding(24)
                .glassCard(radius: 24)
                .padding(20)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }
                }
            }
            .preferredColorScheme(.dark)
        }
    }

    private func authenticate() {
        guard email.contains("@"), password.count >= 6 else {
            errorMessage = "Enter a valid email and a password with at least 6 characters."
            return
        }
        isAuthenticated = true
        dismiss()
    }
}

private struct AuthField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var isSecure = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(MerLuyTheme.indigo)
                .frame(width: 22)
            if isSecure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
            }
        }
        .font(.system(size: 14))
        .padding(.horizontal, 14)
        .frame(minHeight: 50)
        .background(Color.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
