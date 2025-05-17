import Foundation

/// Represents a chat message in the app
struct Message: Identifiable, Codable, Equatable {
  /// Unique identifier for the message
  var id: UUID

  /// Role of the message sender (user or assistant)
  var role: MessageRole

  /// Content of the message
  var content: String

  /// Timestamp when the message was created
  var timestamp: Date

  /// Initialize a new message
  /// - Parameters:
  ///   - id: Optional UUID (defaults to a new random UUID)
  ///   - role: Role of the message sender
  ///   - content: Content of the message
  ///   - timestamp: Optional timestamp (defaults to current date/time)
  init(
    id: UUID = UUID(),
    role: MessageRole,
    content: String,
    timestamp: Date = Date()
  ) {
    self.id = id
    self.role = role
    self.content = content
    self.timestamp = timestamp
  }

  static func == (lhs: Message, rhs: Message) -> Bool {
    lhs.id == rhs.id
  }
}

/// Role of a message sender
enum MessageRole: String, Codable {
  case user
  case assistant
}

// Extension for API compatibility
extension Message {
  /// Get a dictionary representation suitable for API requests
  var apiRepresentation: [String: String] {
    [
      "role": role.rawValue,
      "content": content,
    ]
  }
}
