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
        VStack {
            gitHubView
            Button {
                loadingCall()
            } label: {
                Text("Login")
            }
            .modifier(ProfileViewModifier(color: .green))
            .scaleEffect(isLoginPressed ? 1.05 : 1.0)
            .opacity(isLoginPressed ? 0.6 : 1.0)
            .pressEvents {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isLoginPressed = true
                }
            } onRelease: {
                withAnimation {
                    isLoginPressed = false
                }
            }
            Spacer()
                .frame(height: 50)
            if isFakeLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                    .scaleEffect(3)
            }
            Spacer()
                .frame(height: 50)
            gitHubDataView
        }
    }

    var gitHubView: some View {
        VStack {
            Button {
                logoRotationAngle += 360
                logger.info("Rotating")
            } label: {
                Image("githublogo")
                    .resizable()
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(logoRotationAngle))
                    .animation(.easeInOut(duration: 2), value: logoRotationAngle)
            }
            Text("GitHub login")
            TextField("GitHub username", text: viewModel.profile.$githubusername)
                .textCase(.lowercase)
                .padding()
                .modifier(ProfileViewModifier(color: .blue))
        }
    }

    var gitHubDataView: some View {
        Section("Make sure your GitHub has following data:") {
            List(viewModel.profile.gitHubData, id: \.self) {
                Text($0)
            }
        }
    }
}

extension ProfileView {
    func loadingCall() {
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
