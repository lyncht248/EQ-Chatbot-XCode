import Foundation

/// Singleton class for application configuration
class AppConfig {
  /// Shared instance
  static let shared = AppConfig()

  /// UserDefaults instance
  private let defaults = UserDefaults.standard

  /// Key for API URL in UserDefaults
  private let apiUrlKey = "api_url"

  /// Default API URL if none is set
  private let defaultApiUrl = "https://your-vercel-api-url.vercel.app"

  /// Private initializer for singleton
  private init() {}

  /// Get the current API URL
  var apiUrl: String {
    get {
      return defaults.string(forKey: apiUrlKey) ?? defaultApiUrl
    }
    set {
      defaults.set(newValue, forKey: apiUrlKey)
      NotificationCenter.default.post(name: .apiUrlChanged, object: nil)
    }
  }
}

/// Extension to hold notification names
extension Notification.Name {
  /// Notification sent when API URL changes
  static let apiUrlChanged = Notification.Name("apiUrlChanged")
}
