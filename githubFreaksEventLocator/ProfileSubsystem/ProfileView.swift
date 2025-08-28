//
//  SettingsView.swift
//
//  Created by Mikhail Khinevich on 11.10.23.
//

import SwiftUI

struct ProfileView: View {
    @AppStorage("logged") var logged = false

    var body: some View {
        if logged {
            LoggedInView(logged: $logged)
        } else {
            LoginView(logged: $logged)
        }
    }
}

#Preview {
    ProfileView()
}

#Preview {
    ProfileView()
}
