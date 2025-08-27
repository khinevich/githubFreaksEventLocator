//
//  ProfileViewModel.swift
//  BarFriendFinder
//
//  Created by Mikhail Khinevich on 12.10.23.
//

import Foundation
import SwiftUI
import OSLog

@Observable class ProfileViewModel {
    var profile = Profile()
    var logger = Logger()

    func getUser() async throws -> GitHubUser {
        logger.info("Getting User Information from server")
        let endpoint = "https://api.github.com/users/\(profile.githubusername)"
        guard let url = URL(string: endpoint) else { throw GitHubErrors.invalidURL}
        // actually this error will be never thrown as url will be always right
        // 

        // GET Request, data: JSON, response: http responce code
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw GitHubErrors.invalidResponse
        }
        do {
            let decoder = JSONDecoder()
            // converFromSnakeCase deletes _ and converts next Letter to Uppercase (avatar_url -> avatarUrl)
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(GitHubUser.self, from: data)
        } catch {
            throw GitHubErrors.invalidData
        }
    }
}

struct ButtonPressAnimationModifier: ViewModifier {
    // struct for animation which makes login button bigger with pressing on it
    var onPress: () -> Void
    var onRelease: () -> Void

    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in onPress() }
                    .onEnded { _ in onRelease() })
    }
}

extension View {
    // animation which makes login button bigger with pressing on it
    func pressEvents(onPress: @escaping (() -> Void), onRelease: @escaping (() -> Void)) -> some View {
        modifier(ButtonPressAnimationModifier(onPress: {
            onPress()
        }, onRelease: {
            onRelease()
        }))
    }
}
