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
        // asynchronous task to perform before this view appears.
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
            VStack(spacing: 20) {
                Spacer()
                
                // GitHub Logo
                Button {
                    logoRotationAngle += 360
                    logger.info("Rotating")
                } label: {
                    Image("githublogo") //
                        .resizable()
                        .frame(width: 100, height: 100)
                        .rotationEffect(.degrees(logoRotationAngle))
                        .animation(.easeInOut(duration: 2), value: logoRotationAngle)
                }

                // Header Text
                Text("Login")
                    .font(.custom("Oswald-Regular", size: 40)) //
                    .fontWeight(.bold)

                Text("Enter your GitHub username to continue")
                    .font(.callout)
                    .foregroundColor(.gray)

                // Username TextField
                HStack {
                    Image(systemName: "person.fill")
                        .foregroundColor(.gray)
                    TextField("GitHub Username", text: viewModel.profile.$githubusername) //
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 5)

                // Login Button
                Button {
                    loadingCall()
                } label: {
                    Text("Login")
                }
                .modifier(ProfileViewModifier(color: .blue)) //
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
                
                // Loading Indicator
                if isFakeLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                        .scaleEffect(2)
                        .padding(.top)
                }
                
                Spacer()
                
                // GitHub Data Requirements View
                gitHubDataView
                    .padding(.bottom)

            }
            .padding(.horizontal, 30)
        }
    }

    var gitHubDataView: some View {
        VStack(spacing: 10) {
            Text("Make sure your GitHub profile includes:")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.bottom, 5)
            
            ForEach(viewModel.profile.gitHubData, id: \.self) { item in //
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text(item)
                        .font(.footnote)
                    Spacer()
                }
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.8))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 5)

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
