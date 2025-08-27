//
//  SettingsView.swift
//  BarFriendFinder
//
//  Created by Mikhail Khinevich on 11.10.23.
//

import SwiftUI
import OSLog
struct ProfileView: View {
    @State private var viewModel = ProfileViewModel()
    @State private var user: GitHubUser?
    @State private var isLoginPressed = false
    @State private var isFakeLoading = false

    // Attributes for ErrorHandling
    @State private var errorText = ""
    @State private var alertWindowShown = false

    // Animation variable for GitHubLogo
    @State private var logoRotationAngle: Double = 0.0
    
    // FocusState to control the keyboard
    @FocusState private var isTextFieldFocused: Bool

    @AppStorage("logged") var logged = false
    @AppStorage("age") var age: Int = 16
    enum AppStorageData: Identifiable {
        case logged
        case age

        var id: Int {
            hashValue
        }
    }

    let logger = Logger()

    // Determines, which View has to be shown
    var body: some View {
        if logged == true {
            loggedView
        } else {
            loginView
        }
    }

    var loggedView: some View {
        VStack(spacing: 20) {
            AsyncImage(url: URL(string: user?.avatarUrl ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(Rectangle())
            } placeholder: {
                Image(systemName: "person.circle")
                    .resizable()
            }
            .frame(width: 250, height: 250)
            .cornerRadius(12)
            List {
                Section("Name") {
                    Text(user?.name ?? "Name Placeholder")
                        .font(.title)
                        //.font(.custom("Oswald-Regular", size: 20))
                }
                Section("Bio") {
                    Text(user?.bio ?? "Bio Placeholder")
                        .font(.title2)
                        //.font(.custom("Oswald-Regular", size: 20))
                }
                Section {
                    Picker("Age", selection: $age) {
                        ForEach(Range(16...64), id: \.self) { age in
                            Text("\(age)")
                                .tag("\(age)")
                        }
                    }
                }
                Button("Log out", action: {
                    logged.toggle()
                    logger.info("Logging out")
                }
                )
            }
        }
        // Adds an asynchronous task to perform before this view appears.
        .task {
            do {
                user = try await viewModel.getUser()
                logger.info("Recieved Information form Server")
            } catch GitHubErrors.invalidURL {
                alertWindowShown.toggle()
                errorText = "Invalid Username"
                logger.info("Invalid Username")
            } catch GitHubErrors.invalidData {
                alertWindowShown.toggle()
                errorText = "Invalid Data or Username"
                logger.info("Invalid Data or Username")
            } catch GitHubErrors.invalidResponse {
                alertWindowShown.toggle()
                errorText = "Invalid Response"
                logger.info("Invalid Response")
            } catch {
                alertWindowShown.toggle()
                errorText = "Unknown Error"
                logger.info("Unknown Error")
            }
        }
        .alert(errorText,
               isPresented: $alertWindowShown) {
            Button("Log out",
                   role: .destructive,
                   action: {
                logged.toggle()
                logger.info("Logging out")
                }
            )
        } message: {
            Text("Yout currently logged as UNKNOWN user. Log out and try again.")
        }
    }

    var loginView: some View {
        ZStack {
            Color(.systemGroupedBackground).edgesIgnoringSafeArea(.all)
            
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 20) {
                        
                        // --- Top Section ---
                        VStack {
                            Button {
                                logoRotationAngle += 360
                                logger.info("Rotating")
                            } label: {
                                Image("githublogo")
                                    .resizable()
                                    .frame(width: 100, height: 100)
                                    .rotationEffect(.degrees(logoRotationAngle))
                                    .animation(.easeInOut(duration: 2), value: logoRotationAngle)
                            }
                            .padding(.top, 50)
                            
                            Text("Login")
                                .font(.custom("Oswald-Regular", size: 44))
                                .fontWeight(.bold)
                        }
                        .padding(.bottom, 30)
                        
                        // --- Input Section ---
                        VStack(spacing: 15) {
                            Text("Enter your GitHub username to continue")
                                .font(.body)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                            
                            HStack {
                                Image(systemName: "person.fill")
                                    .foregroundColor(.gray)
                                    .padding(.leading)
                                TextField("GitHub Username", text: viewModel.profile.$githubusername)
                                    .textInputAutocapitalization(.never)
                                    .disableAutocorrection(true)
                                    .font(.body)
                                    .padding(.vertical, 16)
                                    .focused($isTextFieldFocused) // Link TextField to FocusState
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
                            
                            if isFakeLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                                    .scaleEffect(2)
                                    .padding(.top, 10)
                            }
                        }
                        
                        Spacer(minLength: 20)
                        
                        gitHubDataView
                        
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom)
                    .frame(minHeight: geometry.size.height)
                    .toolbar {
                        // Add a toolbar specifically for the keyboard
                        ToolbarItemGroup(placement: .keyboard) {
                            Spacer() // Pushes the button to the right
                            Button("Done") {
                                isTextFieldFocused = false // Dismisses the keyboard
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
}

extension ProfileView {
    func loadingCall() {
        isTextFieldFocused = false // Dismiss keyboard before loading
        isFakeLoading = true
        logger.info("Loading...")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isFakeLoading = false
            logged.toggle()
        }
    }
}

#Preview {
    ProfileView()
}
