import SwiftUI

/// View for displaying a single message bubble in the chat
struct MessageBubbleView: View {
  /// Message to display
  let message: Message

  /// Colors for the different roles
  private var backgroundColor: Color {
    message.role == .user ? Color.blue : Color(.systemGray5)
  }

  private var foregroundColor: Color {
    message.role == .user ? .white : .primary
  }

  private var alignment: Alignment {
    message.role == .user ? .trailing : .leading
  }

  var body: some View {
    HStack {
      if message.role == .user {
        Spacer()
      }

      Text(message.content)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(backgroundColor)
        .foregroundColor(foregroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .contextMenu {
          Button(action: {
            UIPasteboard.general.string = message.content
          }) {
            Label("Copy", systemImage: "doc.on.doc")
          }
        }

      if message.role == .assistant {
        Spacer()
      }
    }
    .padding(.horizontal, 8)
    .padding(.vertical, 4)
  }
}

struct MessageBubbleView_Previews: PreviewProvider {
  static var previews: some View {
    VStack {
      MessageBubbleView(message: Message(role: .user, content: "Hello, how are you?"))
      MessageBubbleView(
        message: Message(
          role: .assistant,
          content: "I'm doing well, thank you for asking! How can I help you today?"))
    }
  }
}
