import Foundation

/// Error types that can occur during API operations
enum APIError: Error {
  case invalidURL
  case networkError(Error)
  case serverError(Int, String)
  case decodingError(Error)
  case unknown

  var localizedDescription: String {
    switch self {
    case .invalidURL:
      return "Invalid URL"
    case .networkError(let error):
      return "Network error: \(error.localizedDescription)"
    case .serverError(let code, let message):
      return "Server error \(code): \(message)"
    case .decodingError(let error):
      return "Failed to decode response: \(error.localizedDescription)"
    case .unknown:
      return "Unknown error occurred"
    }
  }
}

/// Service for handling API requests to the backend
class APIClient {
  /// Shared instance for singleton access
  static let shared = APIClient()

  /// Base URL for the API
  private let baseURL: String

  /// URLSession for network requests
  private let session: URLSession

  /// Initialize with custom configuration
  /// - Parameters:
  ///   - baseURL: Base URL for the API (default: placeholder to be replaced)
  ///   - session: URLSession for network requests (default: shared session)
  init(
    baseURL: String = "http://localhost:3000",  // TODO: Replace with Vercel URL
    session: URLSession = .shared
  ) {
    self.baseURL = baseURL
    self.session = session
  }

  /// Send a message to the chatbot and get a response
  /// - Parameters:
  ///   - userId: ID of the current user
  ///   - messages: Array of message objects
  /// - Returns: The assistant's reply as a string
  func sendMessage(userId: String, messages: [Message]) async throws -> String {
    guard let url = URL(string: "\(baseURL)/chat") else {
      throw APIError.invalidURL
    }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")

    // Convert messages to the format expected by the API
    let messageData = messages.map { ["role": $0.role.rawValue, "content": $0.content] }

    // Create a Codable struct for the request body
    struct ChatRequest: Codable {
      let userId: String
      let messages: [[String: String]]
    }

    let requestBody = ChatRequest(userId: userId, messages: messageData)
    request.httpBody = try JSONEncoder().encode(requestBody)

    let (data, response) = try await session.data(for: request)

    guard let httpResponse = response as? HTTPURLResponse else {
      throw APIError.unknown
    }

    // Check for successful response
    if httpResponse.statusCode == 200 {
      // Decode the response
      let responseData = try JSONDecoder().decode([String: String].self, from: data)

      if let reply = responseData["reply"] {
        return reply
      } else {
        throw APIError.unknown
      }
    } else {
      // Handle error response
      let errorMessage =
        (try? JSONDecoder().decode([String: String].self, from: data)["error"]) ?? "Unknown error"
      throw APIError.serverError(httpResponse.statusCode, errorMessage)
    }
  }

  /// Get chat history for a user
  /// - Parameter userId: ID of the user to get history for
  /// - Returns: Array of messages in the chat history
  func getChatHistory(userId: String) async throws -> [Message] {
    guard let url = URL(string: "\(baseURL)/chat/history/\(userId)") else {
      throw APIError.invalidURL
    }

    var request = URLRequest(url: url)
    request.httpMethod = "GET"

    let (data, response) = try await session.data(for: request)

    guard let httpResponse = response as? HTTPURLResponse else {
      throw APIError.unknown
    }

    if httpResponse.statusCode == 200 {
      // Decode the response
      let responseData = try JSONDecoder().decode([String: [[String: String]]].self, from: data)

      if let historyData = responseData["history"] {
        // Convert API response to Message objects
        return historyData.compactMap { messageDict in
          guard let roleString = messageDict["role"],
            let content = messageDict["content"],
            let timestamp = messageDict["created_at"].flatMap({
              ISO8601DateFormatter().date(from: $0)
            }),
            let role = MessageRole(rawValue: roleString)
          else {
            return nil
          }

          return Message(id: UUID(), role: role, content: content, timestamp: timestamp)
        }
      } else {
        return []
      }
    } else {
      // Handle error response
      let errorMessage =
        (try? JSONDecoder().decode([String: String].self, from: data)["error"]) ?? "Unknown error"
      throw APIError.serverError(httpResponse.statusCode, errorMessage)
    }
  }
}
