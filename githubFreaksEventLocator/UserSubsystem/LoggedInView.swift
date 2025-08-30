//
//  LoggedInView.swift
//  githubFreaksEventLocator
//
//  Created by Mikhail Khinevich on 28.08.25.
//

import SwiftUI
import OSLog

struct LoggedInView: View {
    @State private var viewModel = ProfileViewModel()
    @State private var user: GitHubUser?
    @Binding var logged: Bool
    
    @AppStorage("age") var age: Int = 16
    @State private var errorText = ""
    @State private var alertWindowShown = false

    let logger = Logger()

    var body: some View {
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
                            logged = false
                            logger.info("Logging out")
                        }) {
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
                logged = false
            }
        } message: {
            Text("There was an issue fetching your GitHub data. Please try again.")
        }
    }
}
#Preview {
    LoggedInView(logged: .constant(true))
}
