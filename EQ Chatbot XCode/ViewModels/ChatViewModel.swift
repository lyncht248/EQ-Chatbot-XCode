import Combine
import Foundation
import SwiftUI

/// ViewModel for managing chat functionality
class ChatViewModel: ObservableObject {
  /// Published array of messages in the chat
  @Published var messages: [Message] = []

  /// Current message being composed by the user
  @Published var currentInput: String = ""

  /// Loading state for when a message is being sent
  @Published var isLoading: Bool = false

  /// Error message if something goes wrong
  @Published var errorMessage: String?

  /// API client for network requests
  private let apiClient: APIClient

  /// Auth service for user information
  private let authService: AuthService

  /// Cancellables for managing subscriptions
  private var cancellables = Set<AnyCancellable>()

  /// Initialize with dependencies
  /// - Parameters:
  ///   - apiClient: API client for network requests (default: shared instance)
  ///   - authService: Auth service for user information (default: shared instance)
  init(
    apiClient: APIClient = .shared,
    authService: AuthService = .shared
  ) {
    self.apiClient = apiClient
    self.authService = authService

    // Add welcome message
    addSystemMessage(content: "Hello! I'm your personal assistant. How can I help you today?")

    // Load chat history if user is signed in
    if let user = authService.currentUser {
      Task {
        await loadChatHistory(for: user.id)
      }
    }
  }

  /// Send a message to the chatbot
  /// - Parameter content: Message content to send
  @MainActor
  func sendMessage() async {
    guard !currentInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
      return
    }

    guard let userId = authService.currentUser?.id else {
      errorMessage = "You need to be signed in to send messages"
      return
    }

    let messageContent = currentInput
    currentInput = ""

    // Add user message to the chat
    let userMessage = Message(role: .user, content: messageContent)
    messages.append(userMessage)

    // Set loading state
    isLoading = true
    errorMessage = nil

    do {
      // Send message to API
      let reply = try await apiClient.sendMessage(
        userId: userId,
        messages: messages
      )

      // Add assistant response to the chat
      let assistantMessage = Message(role: .assistant, content: reply)
      messages.append(assistantMessage)
    } catch {
      if let apiError = error as? APIError {
        errorMessage = apiError.localizedDescription
      } else {
        errorMessage = "Failed to send message: \(error.localizedDescription)"
      }
    }

    // Clear loading state
    isLoading = false
  }

  /// Add a system message to the chat
  /// - Parameter content: Content of the system message
  private func addSystemMessage(content: String) {
    let message = Message(role: .assistant, content: content)
    messages.append(message)
  }

  /// Load chat history for a user
  /// - Parameter userId: ID of the user
  @MainActor
  private func loadChatHistory(for userId: String) async {
    do {
      let history = try await apiClient.getChatHistory(userId: userId)

      // If we have history, replace our messages array
      if !history.isEmpty {
        messages = history
      }
    } catch {
      print("Failed to load chat history: \(error.localizedDescription)")
      // Don't show error UI for history loading failure
      // Just continue with the welcome message
    }
  }

  /// Clear all messages in the chat
  func clearChat() {
    messages = []
    addSystemMessage(content: "Chat cleared. How can I help you today?")
  }
}
