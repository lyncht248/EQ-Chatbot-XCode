import SwiftUI

/// Settings view for the app
struct SettingsView: View {
  /// Auth service for user authentication
  @ObservedObject private var authService = AuthService.shared

  /// API client for accessing API configuration
  private let apiClient = APIClient.shared

  /// State for the API URL setting
  @State private var apiURL: String =
    UserDefaults.standard.string(forKey: "api_url") ?? "https://your-vercel-api-url.vercel.app"

  /// App version info
  private var appVersion: String {
    let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    return "Version \(version) (\(build))"
  }

  var body: some View {
    Form {
      Section(header: Text("Account")) {
        if let user = authService.currentUser {
          HStack {
            Text("User ID")
            Spacer()
            Text(user.id.prefix(8) + "...")
              .foregroundColor(.secondary)
          }
        }

        Button(action: {
          authService.signOut()
        }) {
          Text("Sign Out")
            .foregroundColor(.red)
        }
      }

      Section(header: Text("API Settings")) {
        TextField("API URL", text: $apiURL)
          .autocapitalization(.none)
          .disableAutocorrection(true)

        Button("Save API URL") {
          // Save to UserDefaults
          UserDefaults.standard.set(apiURL, forKey: "api_url")

          // Reset API client
          // In a real app, we would have a more elegant way to update this
          // This is a simplification for the MVP
        }
      }

      Section(header: Text("About")) {
        HStack {
          Text("Version")
          Spacer()
          Text(appVersion)
            .foregroundColor(.secondary)
        }
      }
    }
    .navigationTitle("Settings")
  }
}

struct SettingsView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      SettingsView()
        .environmentObject(AuthService.shared)
    }
  }
}
