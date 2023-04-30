import AppKit
import Cocoa
import SafariServices
import WebKit

let extensionBundleIdentifier = "com.premid.PreMiD.Extension"

struct ScriptMessage: Codable {
    let type: String
    let url: String?
}

class ViewController: NSViewController, WKNavigationDelegate, WKScriptMessageHandler {
    @IBOutlet var webView: CustomWebView!

    override func viewDidLoad() {
        super.viewDidLoad()

        webView.navigationDelegate = self

        webView.configuration.userContentController.add(self, name: "controller")

        webView.loadFileURL(Bundle.main.url(forResource: "index", withExtension: "html")!, allowingReadAccessTo: Bundle.main.resourceURL!)
    }

    @IBAction func showHelp(_: AnyObject) {
        if let url = URL(string: "https://docs.premid.app/") {
            NSWorkspace.shared.open(url)
        }
    }

    func webView(_ webView: WKWebView, didFinish _: WKNavigation!) {
        SFSafariExtensionManager.getStateOfSafariExtension(withIdentifier: extensionBundleIdentifier) { state, error in
            guard let state = state, error == nil else {
                let description = "\(String(describing: error))"
                let alert = NSAlert()
                alert.messageText = "Error occurred"
                alert.informativeText = description
                alert.addButton(withTitle: "OK")
                alert.alertStyle = .critical
                let modalResponse = alert.runModal()

                if modalResponse == NSApplication.ModalResponse.alertFirstButtonReturn {
                    NSApplication.shared.terminate(nil)
                }

                return
            }

            DispatchQueue.main.async {
                if #available(macOS 13, *) {
                    webView.evaluateJavaScript("show(\(state.isEnabled), true)")
                } else {
                    webView.evaluateJavaScript("show(\(state.isEnabled), false)")
                }
            }
        }
    }

    func userContentController(_: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let bodyString = message.body as? String,
              let bodyData = bodyString.data(using: .utf8)
        else {
            return
        }

        let bodyStruct = try? JSONDecoder().decode(ScriptMessage.self, from: bodyData)

        if bodyStruct!.type == "open-preferences" {
            SFSafariApplication.showPreferencesForExtension(withIdentifier: extensionBundleIdentifier)
        }

        if bodyStruct!.type == "open-url" && bodyStruct?.url != nil {
            guard let url = URL(string: bodyStruct?.url ?? "") else { return }
            NSWorkspace.shared.open(url)
        }
    }
}
