//
//  ViewModifier.swift
//  GithubFreaksEventLocatorApp
//
//  Created by Mikhail Khinevich on 14.10.23.
//

import Foundation
import SwiftUI
struct PlaceViewModifier: ViewModifier {
    let color: Color
    func body(content: Content) -> some View {
        content
            .font(.headline)
            .foregroundColor(.white)
            .frame(width: 160, height: 48)
            .background(color)
            .cornerRadius(12)
    }
}
