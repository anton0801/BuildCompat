import SwiftUI

// MARK: - Welcome Screen
struct WelcomeView: View {
    @State private var showLogin = false
    @State private var showRegister = false
    @State private var headerScale: CGFloat = 0.9
    @State private var headerOpacity: Double = 0

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "#0F172A"), Color(hex: "#1E293B")],
                startPoint: .top, endPoint: .bottom
            ).ignoresSafeArea()

            // Background pattern
            GeometryReader { geo in
                ForEach(0..<8, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.white.opacity(0.04), lineWidth: 1)
                        .frame(width: 60, height: 60)
                        .rotationEffect(.degrees(45))
                        .offset(
                            x: CGFloat(i % 4) * (geo.size.width / 3),
                            y: CGFloat(i / 4) * 200 + 40
                        )
                }
            }

            VStack(spacing: 0) {
                Spacer()

                // Logo area
                VStack(spacing: 20) {
                    // Layered material icon
                    ZStack {
                        let colors: [Color] = [.bcConcrete, .bcWood, .bcTile, .bcPaint, .bcAccent]
                        ForEach(0..<5, id: \.self) { i in
                            RoundedRectangle(cornerRadius: 6)
                                .fill(colors[i].opacity(0.9))
                                .frame(width: 60 - CGFloat(i) * 6, height: 12)
                                .offset(y: CGFloat(i - 2) * 14)
                                .shadow(color: colors[i].opacity(0.4), radius: 6, y: 3)
                        }
                    }
                    .frame(width: 80, height: 80)

                    Text("BuildCompat")
                        .font(BCFont.display(36))
                        .foregroundColor(.white)

                    Text("Match materials correctly")
                        .font(BCFont.body(16, weight: .medium))
                        .foregroundColor(Color.white.opacity(0.5))
                }
                .scaleEffect(headerScale)
                .opacity(headerOpacity)

                Spacer()

                // Buttons
                VStack(spacing: 12) {
                    Button {
                        showRegister = true
                    } label: {
                        Text("Get Started")
                    }
                    .buttonStyle(BCPrimaryButtonStyle())

                    Button {
                        showLogin = true
                    } label: {
                        Text("Log In")
                    }
                    .buttonStyle(BCSecondaryButtonStyle())

                    // Demo button
                    NavigationLink(destination: EmptyView()) {
                        EmptyView()
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
            }
        }
        .fullScreenCover(isPresented: $showLogin) { LoginView() }
        .fullScreenCover(isPresented: $showRegister) { RegisterView() }
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.2)) {
                headerScale = 1.0
                headerOpacity = 1.0
            }
        }
    }
}

// MARK: - Login View
struct LoginView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.dismiss) var dismiss
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showPassword: Bool = false
    @FocusState private var focusedField: Field?

    enum Field { case email, password }

    var body: some View {
        ZStack {
            Color.bcBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 8) {
                        HStack {
                            Button { dismiss() } label: {
                                Image(systemName: "xmark")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.bcTextSecondary)
                                    .frame(width: 36, height: 36)
                                    .background(Color.bcButtonSecondary)
                                    .clipShape(Circle())
                            }
                            Spacer()
                        }
                        .padding(.bottom, 24)

                        Text("Welcome back")
                            .font(BCFont.display(28))
                            .foregroundColor(.bcTextPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Text("Sign in to continue")
                            .font(BCFont.body(15))
                            .foregroundColor(.bcTextSecondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)

                    // Demo account button
                    Button {
                        authVM.loginWithDemo()
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "bolt.circle.fill")
                                .foregroundColor(.bcAccent)
                                .font(.system(size: 18))
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Continue with Demo Account")
                                    .font(BCFont.body(14, weight: .semibold))
                                    .foregroundColor(.bcAccent)
                                Text("No sign-up required")
                                    .font(BCFont.body(12))
                                    .foregroundColor(.bcTextSecondary)
                            }
                            Spacer()
                            Image(systemName: "arrow.right")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.bcAccent)
                        }
                        .padding(16)
                        .background(Color.bcAccent.opacity(0.08))
                        .cornerRadius(14)
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.bcAccent.opacity(0.3), lineWidth: 1))
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 32)

                    // Divider
                    HStack {
                        Rectangle().fill(Color.bcBorder).frame(height: 1)
                        Text("or").font(BCFont.body(13)).foregroundColor(.bcTextMuted).padding(.horizontal, 12)
                        Rectangle().fill(Color.bcBorder).frame(height: 1)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 20)

                    // Form
                    VStack(spacing: 16) {
                        BCTextField(placeholder: "Email", text: $email, icon: "envelope")
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .focused($focusedField, equals: .email)

                        ZStack(alignment: .trailing) {
                            BCTextField(placeholder: "Password", text: $password, icon: "lock",
                                        isSecure: !showPassword)
                                .focused($focusedField, equals: .password)
                            Button {
                                showPassword.toggle()
                            } label: {
                                Image(systemName: showPassword ? "eye.slash" : "eye")
                                    .foregroundColor(.bcTextMuted)
                                    .padding(.trailing, 16)
                            }
                        }

                        if let error = authVM.errorMessage {
                            HStack {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .foregroundColor(.bcIncompatible)
                                Text(error)
                                    .font(BCFont.body(13))
                                    .foregroundColor(.bcIncompatible)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding(.horizontal, 24)

                    // Login button
                    Button {
                        authVM.errorMessage = nil
                        authVM.login(email: email, password: password)
                    } label: {
                        if authVM.isLoading {
                            ProgressView().tint(.white)
                        } else {
                            Text("Log In")
                        }
                    }
                    .buttonStyle(BCPrimaryButtonStyle())
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                    .disabled(authVM.isLoading)
                }
            }
        }
    }
}

// MARK: - Register View
struct RegisterView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.dismiss) var dismiss
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showPassword: Bool = false

    var body: some View {
        ZStack {
            Color.bcBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    VStack(spacing: 8) {
                        HStack {
                            Button { dismiss() } label: {
                                Image(systemName: "xmark")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.bcTextSecondary)
                                    .frame(width: 36, height: 36)
                                    .background(Color.bcButtonSecondary)
                                    .clipShape(Circle())
                            }
                            Spacer()
                        }
                        .padding(.bottom, 24)

                        Text("Create account")
                            .font(BCFont.display(28))
                            .foregroundColor(.bcTextPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("Start checking compatibility")
                            .font(BCFont.body(15))
                            .foregroundColor(.bcTextSecondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)

                    // Demo
                    Button {
                        authVM.loginWithDemo()
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "bolt.circle.fill")
                                .foregroundColor(.bcAccent).font(.system(size: 18))
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Try Demo Account")
                                    .font(BCFont.body(14, weight: .semibold)).foregroundColor(.bcAccent)
                                Text("Explore all features instantly")
                                    .font(BCFont.body(12)).foregroundColor(.bcTextSecondary)
                            }
                            Spacer()
                            Image(systemName: "arrow.right")
                                .font(.system(size: 13, weight: .semibold)).foregroundColor(.bcAccent)
                        }
                        .padding(16)
                        .background(Color.bcAccent.opacity(0.08))
                        .cornerRadius(14)
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.bcAccent.opacity(0.3), lineWidth: 1))
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 32)

                    HStack {
                        Rectangle().fill(Color.bcBorder).frame(height: 1)
                        Text("or").font(BCFont.body(13)).foregroundColor(.bcTextMuted).padding(.horizontal, 12)
                        Rectangle().fill(Color.bcBorder).frame(height: 1)
                    }
                    .padding(.horizontal, 24).padding(.vertical, 20)

                    VStack(spacing: 16) {
                        BCTextField(placeholder: "Full Name", text: $name, icon: "person")
                        BCTextField(placeholder: "Email", text: $email, icon: "envelope")
                            .keyboardType(.emailAddress).autocapitalization(.none)
                        ZStack(alignment: .trailing) {
                            BCTextField(placeholder: "Password", text: $password, icon: "lock",
                                        isSecure: !showPassword)
                            Button { showPassword.toggle() } label: {
                                Image(systemName: showPassword ? "eye.slash" : "eye")
                                    .foregroundColor(.bcTextMuted).padding(.trailing, 16)
                            }
                        }
                        if let error = authVM.errorMessage {
                            HStack {
                                Image(systemName: "exclamationmark.circle.fill").foregroundColor(.bcIncompatible)
                                Text(error).font(BCFont.body(13)).foregroundColor(.bcIncompatible)
                            }.frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding(.horizontal, 24)

                    Button {
                        authVM.errorMessage = nil
                        authVM.register(name: name, email: email, password: password)
                    } label: {
                        if authVM.isLoading { ProgressView().tint(.white) }
                        else { Text("Create Account") }
                    }
                    .buttonStyle(BCPrimaryButtonStyle())
                    .padding(.horizontal, 24).padding(.top, 24)
                    .disabled(authVM.isLoading)

                    Spacer(minLength: 40)
                }
            }
        }
    }
}

// MARK: - Custom Text Field
struct BCTextField: View {
    let placeholder: String
    @Binding var text: String
    let icon: String
    var isSecure: Bool = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.bcTextMuted)
                .frame(width: 20)
            if isSecure {
                SecureField(placeholder, text: $text)
                    .font(BCFont.body(15))
                    .foregroundColor(.bcTextPrimary)
            } else {
                TextField(placeholder, text: $text)
                    .font(BCFont.body(15))
                    .foregroundColor(.bcTextPrimary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.bcCard)
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.bcBorder, lineWidth: 1))
    }
}
