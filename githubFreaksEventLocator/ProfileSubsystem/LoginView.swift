//
//  LoginView.swift
//  githubFreaksEventLocator
//
//  Created by Mikhail Khinevich on 28.08.25.
//

import SwiftUI
import OSLog

struct LoginView: View {
    @State private var viewModel = ProfileViewModel()
    @Binding var logged: Bool
    
    @State private var isLoginPressed = false
    @State private var isFakeLoading = false
    @State private var logoRotationAngle: Double = 0.0
    @FocusState private var isTextFieldFocused: Bool

    let logger = Logger()

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).edgesIgnoringSafeArea(.all)
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 20) {
                        VStack {
                            Button {
                                if !isFakeLoading {
                                    logoRotationAngle += 360
                                }
                            } label: {
                                Image("githublogo")
                                    .resizable()
                                    .frame(width: 100, height: 100)
                                    .rotationEffect(.degrees(logoRotationAngle))
                                    .animation(
                                        isFakeLoading
                                            ? .linear(duration: 1).repeatForever(autoreverses: false)
                                            : .easeInOut(duration: 2),
                                        value: logoRotationAngle
                                    )
                            }
                            .padding(.top, 50)
                            
                            Text("Login")
                                .font(.custom("Oswald-Regular", size: 44))
                                .fontWeight(.bold)
                        }
                        .padding(.bottom, 30)
                        
                        VStack(spacing: 15) {
                            Text("Enter your GitHub username to continue")
                                .font(.body)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                            
                            HStack {
                                Image(systemName: "person.fill")
                                    .foregroundColor(.gray)
                                    .padding(.leading)
                                TextField("GitHub Username", text: $viewModel.profile.githubusername)
                                    .textInputAutocapitalization(.never)
                                    .disableAutocorrection(true)
                                    .font(.body)
                                    .padding(.vertical, 16)
                                    .focused($isTextFieldFocused)
                            }
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 5)
                            
                            Button {
                                loadingCall()
                            } label: {
                                Text("Login")
                            }
                            .modifier(ProfileViewModifier(color: .blue))
                            .scaleEffect(isLoginPressed ? 1.05 : 1.0)
                            .opacity(isLoginPressed ? 0.6 : 1.0)
                            .pressEvents {
                                withAnimation(.easeInOut(duration: 0.1)) { isLoginPressed = true }
                            } onRelease: {
                                withAnimation { isLoginPressed = false }
                            }
                        }
                        
                        Spacer(minLength: 20)
                        gitHubDataView
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom)
                    .frame(minHeight: geometry.size.height)
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            Spacer()
                            Button("Done") {
                                isTextFieldFocused = false
                            }
                        }
                    }
                }
            }
        }
        .onTapGesture {
            isTextFieldFocused = false
        }
    }

    var gitHubDataView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Make sure your GitHub profile includes:")
                .font(.body)
                .foregroundColor(.secondary)
                .padding(.bottom, 5)
            
            ForEach(viewModel.profile.gitHubData, id: \.self) { item in
                HStack(spacing: 10) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text(item)
                        .font(.callout)
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground).opacity(0.8))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 5)
    }

    func loadingCall() {
        isTextFieldFocused = false
        isFakeLoading = true
        logoRotationAngle += 360
        logger.info("Loading...")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isFakeLoading = false
            logged = true
        }
    }
}
#Preview {
    LoginView(logged: .constant(false))
}
