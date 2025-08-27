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
        ZStack(alignment: .top) {
            Color(.systemGroupedBackground).ignoresSafeArea()
            ScrollView {
                VStack(spacing: 15) {
                    // --- Profile Header Image with Overlays ---
                    ZStack(alignment: .bottomLeading) {
                        // Profile Image
                        AsyncImage(url: URL(string: user?.avatarUrl ?? "")) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 350)
                                .clipped()
                        } placeholder: {
                            Rectangle()
                                .fill(.gray.opacity(0.1))
                                .frame(height: 350)
                                .overlay {
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 80))
                                        .foregroundStyle(.gray.opacity(0.5))
                                }
                        }
                        // Gradient for text readability
                        LinearGradient(
                            colors: [.clear, .black.opacity(0.7)],
                            startPoint: .center,
                            endPoint: .bottom
                        )
                        // Name Overlay
                        Text(user?.name ?? "Name Placeholder")
                            .font(.largeTitle.weight(.bold))
                            .foregroundStyle(.white)
                            .shadow(radius: 5)
                            .padding()
                    }
                    // --- Content Sections ---
                    VStack(spacing: 15) {
                        // Bio Section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("BIO")
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(.secondary)
                            Text(user?.bio ?? "No bio available.")
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        // Age Section
                        HStack {
                            Text("AGE")
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(.secondary)
                            Spacer()
                            Picker("Age", selection: $age) {
                                ForEach(16...99, id: \.self) { number in
                                    Text("\(number)").tag(number)
                                }
                            }
                            .pickerStyle(.menu)
                            .tint(.secondary)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 4)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        // Log Out Button Section
                        Button(action: {
                            logged.toggle()
                            logger.info("Logging out")
                            }
                        ){
                            HStack {
                                Spacer()
                                Text("Log Out")
                                    .font(.body.weight(.semibold))
                                    .foregroundColor(.red)
                                Spacer()
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding([.horizontal, .bottom])
                }
            }
        }
        .ignoresSafeArea(edges: .top)
        .task {
            do {
                user = try await viewModel.getUser()
                logger.info("Received Information from Server")
            } catch {
                errorText = "Could not load profile."
                alertWindowShown = true
                logger.error("Error fetching user: \(error.localizedDescription)")
            }
        }
        .alert(errorText, isPresented: $alertWindowShown) {
            Button("Log out", role: .destructive) {
                logged.toggle()
            }
        } message: {
            Text("There was an issue fetching your GitHub data. Please try again.")
        }
    }

    var loginView: some View {
        ZStack {
            Color(.systemGroupedBackground).edgesIgnoringSafeArea(.all)
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 20) {
                        VStack {
                            Button {
                                // Only allow manual spin if not loading
                                if !isFakeLoading {
                                    logoRotationAngle += 360
                                }
                            } label: {
                                Image("githublogo")
                                    .resizable()
                                    .frame(width: 100, height: 100)
                                    .rotationEffect(.degrees(logoRotationAngle))
                                    // This animation modifier dynamically changes based on the loading state
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
                                TextField("GitHub Username", text: viewModel.profile.$githubusername)
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
}

extension ProfileView {
    func loadingCall() {
        isTextFieldFocused = false
        isFakeLoading = true
        // This change to the angle value will trigger the .repeatForever animation
        logoRotationAngle += 360
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
