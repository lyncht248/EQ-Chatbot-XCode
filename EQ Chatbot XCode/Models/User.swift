import Foundation

/// Represents a user in the app
struct User: Identifiable, Codable {
  /// Unique identifier for the user
  var id: String

  /// User's display name
  var name: String?

  /// User's email address
  var email: String?

  /// Initialize a new user
  /// - Parameters:
  ///   - id: User's unique identifier
  ///   - name: Optional display name
  ///   - email: Optional email address
  init(id: String, name: String? = nil, email: String? = nil) {
    self.id = id
    self.name = name
    self.email = email
  }
}
