import WebKit

class CustomWebView: WKWebView {
    override func willOpenMenu(_ menu: NSMenu, with _: NSEvent) {
        if let reloadMenuItem = menu.item(withTitle: "Reload") {
            menu.removeItem(reloadMenuItem)
        }
    }
}
