//
//  EQ_Chatbot_XCodeApp.swift
//  EQ Chatbot XCode
//
//  Created by Thomas Lynch on 04/05/2025.
//

import SwiftUI

@main
struct EQ_Chatbot_XCodeApp: App {
  /// Auth service for user authentication
  @StateObject private var authService = AuthService.shared

  var body: some Scene {
    WindowGroup {
      MainView()
        .environmentObject(authService)
    }
  }
}

/// Main container view that handles navigation and auth state
struct MainView: View {
  /// Auth service for determining signed-in state
  @EnvironmentObject private var authService: AuthService

  var body: some View {
    if authService.isSignedIn {
      // User is signed in, show main tab view
      TabView {
        NavigationView {
          ChatView()
        }
        .tabItem {
          Label("Chat", systemImage: "bubble.left.and.bubble.right")
        }

        NavigationView {
          SettingsView()
        }
        .tabItem {
          Label("Settings", systemImage: "gear")
        }
      }
    } else {
      // User is not signed in, show welcome view
      WelcomeView()
    }
  }
}
