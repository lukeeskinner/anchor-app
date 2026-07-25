//
//  AuthView.swift
//  anchor
//
//  Created by Luke Skinner on 7/12/26.
//

import SwiftUI

struct AuthView: View {

    enum Mode {
        case login, signup
    }

    @State private var mode: Mode
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var isPasswordVisible = false
    @FocusState private var focus: Field?

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private enum Field {
        case name, email, password
    }

    init(mode: Mode = .login) {
        _mode = State(initialValue: mode)
    }

    private var isFormValid: Bool {
        let emailOK = email.contains("@") && email.contains(".")
        let passwordOK = password.count >= 8
        let nameOK = mode == .login
            || !name.trimmingCharacters(in: .whitespaces).isEmpty
        return emailOK && passwordOK && nameOK
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                header

                modePicker
                    .padding(.top, 28)

                fields
                    .padding(.top, 30)

                submitButton
                    .padding(.top, 28)
            }
            .padding(.horizontal, 24)
            .padding(.top, 36)
            .padding(.bottom, 32)
            .frame(maxWidth: 480)
            .frame(maxWidth: .infinity)
        }
        .scrollBounceBehavior(.basedOnSize)
        .scrollDismissesKeyboard(.interactively)
        .background {
            Colors.background.ignoresSafeArea()
        }
    }

    private var header: some View {
        VStack(spacing: 9) {
            Text("Get Started Now")
                .font(.system(.title, design: .rounded, weight: .bold))
                .foregroundStyle(Colors.textPrimary)

            Text("Create an account or log in to find your best focus.")
                .font(.subheadline)
                .foregroundStyle(Colors.textSecondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 310)
        }
    }

    private var modePicker: some View {
        HStack(spacing: 4) {
            modeButton("Sign Up", mode: .signup)
            modeButton("Log In", mode: .login)
        }
        .padding(4)
        .frame(height: 54)
        .background(
            Colors.surfaceTint.opacity(0.72),
            in: RoundedRectangle(cornerRadius: 18, style: .continuous)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(Colors.border.opacity(0.8), lineWidth: 1)
        }
    }

    private func modeButton(_ title: String, mode selection: Mode) -> some View {
        let isSelected = mode == selection

        return Button {
            switchMode(to: selection)
        } label: {
            Text(title)
                .font(.system(.subheadline, design: .rounded, weight: .semibold))
                .foregroundStyle(isSelected ? .white : Colors.textSecondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Colors.primary)
                            .shadow(color: Colors.primary.opacity(0.25), radius: 8, y: 4)
                    }
                }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var fields: some View {
        VStack(spacing: 18) {
            if mode == .signup {
                labeledField("Full Name", focused: focus == .name) {
                    TextField("Your full name", text: $name)
                        .textContentType(.name)
                        .focused($focus, equals: .name)
                        .submitLabel(.next)
                        .onSubmit { focus = .email }
                }
                .transition(.move(edge: .top).combined(with: .opacity))
            }

            labeledField("Email", focused: focus == .email) {
                TextField("you@example.com", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .focused($focus, equals: .email)
                    .submitLabel(.next)
                    .onSubmit { focus = .password }
            }

            VStack(alignment: .leading, spacing: 8) {
                labeledField("Password", focused: focus == .password) {
                    Group {
                        if isPasswordVisible {
                            TextField("At least 8 characters", text: $password)
                        } else {
                            SecureField("At least 8 characters", text: $password)
                        }
                    }
                    .textContentType(mode == .login ? .password : .newPassword)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .focused($focus, equals: .password)
                    .submitLabel(.go)
                    .onSubmit(submit)

                    Button {
                        isPasswordVisible.toggle()
                    } label: {
                        Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(Colors.textSecondary)
                            .frame(width: 32, height: 32)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(
                        isPasswordVisible ? "Hide password" : "Show password"
                    )
                }

                if mode == .login {
                    Button("Forgot password?") {
                        // TODO: password reset
                    }
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Colors.primary)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
        }
    }

    private func labeledField(
        _ label: String,
        focused: Bool,
        @ViewBuilder content: () -> some View
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Colors.textPrimary)

            HStack(spacing: 10) {
                content()
                    .foregroundStyle(Colors.textPrimary)
            }
            .padding(.horizontal, 16)
            .frame(height: 54)
            .background(
                Colors.surfaceTint.opacity(0.62),
                in: RoundedRectangle(cornerRadius: 17, style: .continuous)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 17, style: .continuous)
                    .strokeBorder(
                        focused ? Colors.primary : Colors.border,
                        lineWidth: focused ? 1.5 : 1
                    )
            }
        }
        .animation(.easeOut(duration: 0.16), value: focused)
    }

    private var submitButton: some View {
        Button(action: submit) {
            Text(mode == .login ? "Log In" : "Sign Up")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Colors.primary, in: Capsule())
        }
        .buttonStyle(.plain)
        .opacity(isFormValid ? 1 : 0.42)
        .disabled(!isFormValid)
    }

    private func switchMode(to selection: Mode) {
        guard selection != mode else { return }
        focus = nil

        if reduceMotion {
            mode = selection
        } else {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.86)) {
                mode = selection
            }
        }
    }

    private func submit() {
        guard isFormValid else { return }
        // TODO: hook up auth backend
    }
}

#Preview("Login") {
    AuthView()
        .preferredColorScheme(.dark)
}

#Preview("Sign Up") {
    AuthView(mode: .signup)
        .preferredColorScheme(.dark)
}
