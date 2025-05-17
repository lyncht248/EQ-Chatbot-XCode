import Foundation
import SwiftUI

/// Service for handling user authentication
class AuthService: ObservableObject {
  /// Shared instance for singleton access
  static let shared = AuthService()

  /// Published property for the current user
  @Published var currentUser: User?

  /// Key for storing user ID in UserDefaults
  private let userIdKey = "com.eqchatbot.userId"

  /// UserDefaults instance
  private let defaults = UserDefaults.standard

  /// Initialize and check for existing user session
  init() {
    // Check if we have a saved user ID
    if let userId = defaults.string(forKey: userIdKey) {
      // Create a temporary user with just the ID
      // In a real app, you'd fetch the full user profile from Supabase/backend
      currentUser = User(id: userId)
    }
  }

  /// Generate a random user ID for demo purposes
  /// - Note: In a real app, this would use Supabase authentication
  func signInAnonymously() {
    let userId = UUID().uuidString
    currentUser = User(id: userId)
    defaults.set(userId, forKey: userIdKey)
  }

  /// Sign out the current user
  func signOut() {
    currentUser = nil
    defaults.removeObject(forKey: userIdKey)
  }

  /// Check if a user is currently signed in
  var isSignedIn: Bool {
    currentUser != nil
  }
}
