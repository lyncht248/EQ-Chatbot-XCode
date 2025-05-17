import SwiftUI

/// Welcome screen shown when the user is not signed in
struct WelcomeView: View {
  /// Auth service for user authentication
  @ObservedObject private var authService = AuthService.shared

  var body: some View {
    VStack(spacing: 30) {
      Spacer()

      // App logo
      Image(systemName: "bubble.left.and.bubble.right.fill")
        .font(.system(size: 80))
        .foregroundColor(.blue)

      // App title
      Text("EQ Chatbot")
        .font(.largeTitle)
        .fontWeight(.bold)

      // App description
      Text("Your personal AI assistant with a human touch")
        .font(.title3)
        .multilineTextAlignment(.center)
        .foregroundColor(.secondary)
        .padding(.horizontal, 20)

      Spacer()

      // Sign in button
      Button(action: {
        authService.signInAnonymously()
      }) {
        HStack {
          Image(systemName: "person.fill")
          Text("Continue as Guest")
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.blue)
        .foregroundColor(.white)
        .cornerRadius(12)
        .padding(.horizontal, 20)
      }
      .padding(.bottom, 50)
    }
    .padding()
  }
}

struct WelcomeView_Previews: PreviewProvider {
  static var previews: some View {
    WelcomeView()
      .environmentObject(AuthService.shared)
  }
}
