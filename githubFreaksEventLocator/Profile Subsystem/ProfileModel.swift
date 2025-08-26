//
//  ProfileModel.swift
//  BarFriendFinder
//
//  Created by Mikhail Khinevich on 12.10.23.
//

import Foundation
import SwiftUI

struct Profile {
    @AppStorage("githubusername") var githubusername: String = ""
    var gitHubData = ["Foto", "Name", "Bio"]
}
struct GitHubUser: Codable {
    let avatarUrl: String
    let bio: String
    let name: String
}

enum GitHubErrors: Error {
    case invalidURL
    case invalidResponse
    case invalidData
}
