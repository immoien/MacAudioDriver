import SwiftUI
import WebKit

struct MainContentView: View {
    @State private var webView: WKWebView = WKWebView()
    @State private var joiningLink: String = ""

    var body: some View {
        VStack {
            TextField("Enter Join URL", text: $joiningLink)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button("Join Meeting") {
                let bbbAPI = BBBAPI(serverURL: "https://dev.cnxmeeting.com", sharedSecret: "gORUBW6vt6SPewg4byt24lwAOOOKgGyfclmlbaXv8")
                bbbAPI.joinMeeting(joinURL: joiningLink) { url in
                    guard let url = url else { return }
                    print("Joining URL: \(url.absoluteString)")
                    NotificationCenter.default.post(name: NSNotification.Name("loadURL"), object: nil, userInfo: ["url": url])
                }
            }

            WebView(webView: $webView)
        }
        .frame(minWidth: 800, minHeight: 600)
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("loadURL"))) { notification in
            if let userInfo = notification.userInfo, let url = userInfo["url"] as? URL {
                webView.load(URLRequest(url: url))
                print("Successfully joined meeting, loading URL: \(url.absoluteString)")
            }
        }
    }
}

struct WebView: NSViewRepresentable {
    @Binding var webView: WKWebView

    func makeNSView(context: Context) -> WKWebView {
        webView.navigationDelegate = context.coordinator
        webView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
        webView.configuration.mediaTypesRequiringUserActionForPlayback = []
        return webView
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        preferences.javaScriptCanOpenWindowsAutomatically = true

        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences
        nsView.configuration.userContentController = configuration.userContentController

        // Inject JavaScript to request media device access
        let scriptSource = """
        navigator.mediaDevices.getUserMedia({ audio: true, video: true })
        .then(stream => {
            console.log('Access granted to media devices');
        })
        .catch(error => {
            console.error('Error accessing media devices', error);
        });
        """
        let script = WKUserScript(source: scriptSource, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        nsView.configuration.userContentController.addUserScript(script)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView

        init(_ parent: WebView) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            webView.evaluateJavaScript("navigator.userAgent") { result, error in
                if let userAgent = result as? String {
                    print("User Agent: \(userAgent)")
                } else if let error = error {
                    print("Error retrieving user agent: \(error.localizedDescription)")
                }
            }
        }
    }
}
