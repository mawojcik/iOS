import Foundation
import SwiftUI
import GoogleSignIn

class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isAuthenticated = false
    @Published var token = ""
    @Published var errorMessage = ""
    @Published var showError = false
    @Published var isLoading = false
    @Published var isLoginMode = true
    @Published var registrationSuccess = false
    @Published var infoText: String? = nil

    private let baseURL = "http://127.0.0.1:8000"
    private let githubClientID = "Ov23liD175Wp0tswmhl5"

    @Published var ghUserCode: String?
    @Published var ghVerificationURL: URL?
    private var ghDeviceCode: String?
    private var ghIntervalSeconds: Int = 5
    private var ghPollingTask: Task<Void, Never>?

    func performAction() {
        if isLoginMode {
            login()
        } else {
            register()
        }
    }

    func logout() {
        GIDSignIn.sharedInstance.signOut()
        stopGitHubFlow()
        isAuthenticated = false
        token = ""
        email = ""
        password = ""
    }

    func googleLogin() {
        isLoading = true
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController else {
            isLoading = false
            return
        }

        GIDSignIn.sharedInstance.signIn(withPresenting: rootVC) { result, error in
            DispatchQueue.main.async {
                self.isLoading = false
                if let result {
                    self.token = result.user.idToken?.tokenString ?? result.user.accessToken.tokenString
                    self.isAuthenticated = true
                }
            }
        }
    }

    @MainActor
    func startGitHubDeviceFlow() async {
        isLoading = true
        stopGitHubFlow()

        do {
            let resp = try await githubRequestDeviceCode()
            ghUserCode = resp.user_code
            ghDeviceCode = resp.device_code
            ghIntervalSeconds = max(resp.interval, 5)
            ghVerificationURL = URL(string: resp.verification_uri)
            isLoading = false

            ghPollingTask = Task {
                await pollGitHubForToken()
            }
        } catch {
            isLoading = false
        }
    }

    @MainActor
    private func pollGitHubForToken() async {
        guard let deviceCode = ghDeviceCode else { return }

        while !Task.isCancelled {
            do {
                let res = try await githubPollAccessToken(deviceCode: deviceCode)
                if let token = res.access_token {
                    self.token = token
                    self.isAuthenticated = true
                    stopGitHubFlow()
                    return
                }
                try await Task.sleep(nanoseconds: UInt64(ghIntervalSeconds) * 1_000_000_000)
            } catch {
                stopGitHubFlow()
                return
            }
        }
    }

    func stopGitHubFlow() {
        ghPollingTask?.cancel()
        ghPollingTask = nil
        ghUserCode = nil
        ghVerificationURL = nil
        ghDeviceCode = nil
    }

    private func formBody(_ dict: [String: String]) -> Data {
        let s = dict.map { key, value in
            let k = key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? key
            let v = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? value
            return "\(k)=\(v)"
        }.joined(separator: "&")
        return Data(s.utf8)
    }


    private func githubRequestDeviceCode() async throws -> GitHubDeviceCodeResponse {
        var req = URLRequest(url: URL(string: "https://github.com/login/device/code")!)
        req.httpMethod = "POST"
        req.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        req.httpBody = formBody([
            "client_id": githubClientID,
            "scope": "read:user user:email"
        ])
        let (data, _) = try await URLSession.shared.data(for: req)
        return try JSONDecoder().decode(GitHubDeviceCodeResponse.self, from: data)
    }

    private func githubPollAccessToken(deviceCode: String) async throws -> GitHubAccessTokenResponse {
        var req = URLRequest(url: URL(string: "https://github.com/login/oauth/access_token")!)
        req.httpMethod = "POST"
        req.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        req.httpBody = formBody([
            "client_id": githubClientID,
            "device_code": deviceCode,
            "grant_type": "urn:ietf:params:oauth:grant-type:device_code"
        ])
        let (data, _) = try await URLSession.shared.data(for: req)
        return try JSONDecoder().decode(GitHubAccessTokenResponse.self, from: data)
    }

    private func login() {}
    private func register() {}
}

struct GitHubDeviceCodeResponse: Codable {
    let device_code: String
    let user_code: String
    let verification_uri: String
    let expires_in: Int
    let interval: Int
}

struct GitHubAccessTokenResponse: Codable {
    let access_token: String?
    let error: String?
}
