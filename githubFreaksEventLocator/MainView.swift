//
//  ContentView.swift
//  BarFriendFinder
//
//  Created by Mikhail Khinevich on 11.10.23.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        TabView {
            ProfileView()
                .tabItem {
                    Image(systemName: "person.crop.circle")
                    Text("Profile")
                }
            MapView()
                .tabItem {
                    Image(systemName: "map")
                    Text("Event Map")
                }
        }
    }
}

#Preview {
    MainView()
}
