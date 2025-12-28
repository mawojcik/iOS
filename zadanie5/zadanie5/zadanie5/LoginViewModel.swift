import Foundation
import SwiftUI
import GoogleSignIn

struct AuthRequest: Codable {
    let email: String
    let password: String
}

struct TokenResponse: Codable {
    let token: String
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

class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isAuthenticated = false
    @Published var token = ""
    @Published var errorMessage = ""
    @Published var showError = false
    @Published var isLoading = false
    @Published var isLoginMode = true
    @Published var infoText: String? = nil

    private let baseURL = "http://127.0.0.1:8000"
    private let githubClientID = "Ov23liD175Wp0tswmhl5"

    @Published var ghUserCode: String?
    @Published var ghVerificationURL: URL?

    private var ghDeviceCode: String?
    private var ghIntervalSeconds = 5
    private var ghPollingTask: Task<Void, Never>?

    func performAction() {
        isLoginMode ? login() : register()
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

        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let root = scene.windows.first(where: { $0.isKeyWindow })?.rootViewController else {
            isLoading = false
            return
        }

        GIDSignIn.sharedInstance.signIn(withPresenting: root) { result, _ in
            DispatchQueue.main.async {
                self.isLoading = false
                guard let result else { return }

                let accessToken = result.user.accessToken.tokenString
                Task {
                    await self.oauthBackendLogin(
                        email: "google_user@oauth.local",
                        password: "GOOGLE_OAUTH"
                    )
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
            ghVerificationURL = URL(string: resp.verification_uri)
            ghDeviceCode = resp.device_code
            ghIntervalSeconds = max(resp.interval, 5)
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
                if let _ = res.access_token {
                    await oauthBackendLogin(
                        email: "github_user@oauth.local",
                        password: "GITHUB_OAUTH"
                    )
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

    @MainActor
    private func oauthBackendLogin(email: String, password: String) async {
        guard let url = URL(string: "\(baseURL)/login") else { return }

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try? JSONEncoder().encode(AuthRequest(email: email, password: password))

        do {
            let (data, response) = try await URLSession.shared.data(for: req)
            if let http = response as? HTTPURLResponse, http.statusCode == 200 {
                let decoded = try JSONDecoder().decode(TokenResponse.self, from: data)
                token = decoded.token
                isAuthenticated = true
                return
            }
            await oauthRegisterThenLogin(email: email, password: password)
        } catch {}
    }

    @MainActor
    private func oauthRegisterThenLogin(email: String, password: String) async {
        guard let url = URL(string: "\(baseURL)/register") else { return }

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try? JSONEncoder().encode(AuthRequest(email: email, password: password))

        do {
            _ = try await URLSession.shared.data(for: req)
            await oauthBackendLogin(email: email, password: password)
        } catch {}
    }

    private func login() {}
    private func register() {}

    private func formBody(_ dict: [String: String]) -> Data {
        let s = dict.map {
            let k = $0.key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? $0.key
            let v = $0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? $0.value
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
}
