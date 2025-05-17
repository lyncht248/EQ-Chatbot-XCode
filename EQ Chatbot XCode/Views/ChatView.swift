import SwiftUI

/// Main view for the chat interface
struct ChatView: View {
  /// ViewModel for the chat functionality
  @StateObject private var viewModel = ChatViewModel()

  /// Scroll position tracker for scrolling to the bottom
  @Namespace private var bottomID

  /// Focus state for the text field
  @FocusState private var isInputFocused: Bool

  var body: some View {
    ZStack {
      VStack(spacing: 0) {
        // Chat messages
        ScrollViewReader { proxy in
          ScrollView {
            LazyVStack(spacing: 0) {
              ForEach(viewModel.messages) { message in
                MessageBubbleView(message: message)
                  .id(message.id)
              }

              // Invisible element at the bottom for scrolling
              Color.clear
                .frame(height: 1)
                .id(bottomID)
            }
            .padding(.vertical, 8)
          }
          .onChange(of: viewModel.messages.count) { _ in
            // Scroll to bottom when messages change
            withAnimation {
              proxy.scrollTo(bottomID, anchor: .bottom)
            }
          }
        }
        .background(Color(.systemBackground))

        // Typing indicator
        if viewModel.isLoading {
          HStack {
            Text("Typing...")
              .font(.caption)
              .foregroundColor(.secondary)
            Spacer()
          }
          .padding(.horizontal)
          .padding(.top, 4)
        }

        // Error message
        if let errorMessage = viewModel.errorMessage {
          Text(errorMessage)
            .font(.caption)
            .foregroundColor(.red)
            .padding(.horizontal)
            .padding(.top, 4)
        }

        // Input area
        HStack(spacing: 12) {
          // Text field for user input
          TextField("Type a message...", text: $viewModel.currentInput, axis: .vertical)
            .padding(12)
            .background(Color(.systemGray6))
            .cornerRadius(20)
            .focused($isInputFocused)
            .submitLabel(.send)
            .onSubmit {
              sendMessage()
            }

          // Send button
          Button(action: sendMessage) {
            Image(systemName: "arrow.up.circle.fill")
              .font(.system(size: 30))
              .foregroundColor(.blue)
          }
          .disabled(
            viewModel.isLoading
              || viewModel.currentInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: -2)
      }
    }
    .navigationTitle("Chat")
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        Button(action: {
          viewModel.clearChat()
        }) {
          Image(systemName: "trash")
        }
      }
    }
  }

  /// Send the current message
  private func sendMessage() {
    Task {
      await viewModel.sendMessage()
    }
  }
}

struct ChatView_Previews: PreviewProvider {
  static var previews: some View {
    ChatView()
      .environmentObject(AuthService.shared)
  }
}
