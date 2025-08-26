//
//  ProfileViewModifier.swift
//  BarFriendFinder
//
//  Created by Mikhail Khinevich on 15.10.23.
//

import Foundation
import SwiftUI
struct ProfileViewModifier: ViewModifier {
    let color: Color
    func body(content: Content) -> some View {
        content
            .font(.headline)
            .frame(width: 250, height: 48)
            .background(Color(color))
            .foregroundColor(.white)
            .cornerRadius(12)
    }
}
