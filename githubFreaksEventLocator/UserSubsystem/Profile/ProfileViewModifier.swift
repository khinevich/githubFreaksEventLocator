//
//  ProfileViewModifier.swift
//  GithubFreaksEventLocatorApp
//
//  Created by Mikhail Khinevich on 15.10.23.
//

import Foundation
import SwiftUI
struct ProfileViewModifier: ViewModifier {
    let color: Color
    func body(content: Content) -> some View {
        content
            .font(.title3.weight(.semibold))
            .frame(maxWidth: .infinity, minHeight: 52)
            .background(Color(color))
            .foregroundColor(.white)
            .cornerRadius(12)
    }
}
