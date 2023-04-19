const openPreferencesSelector = document.querySelector("button.open-preferences");
const supportLinkSelector = document.querySelector("a.support-link");
const downloadLinkSelector = document.querySelector("a.download-link");

function show(enabled, _) {
    if (typeof enabled !== "boolean") {
        document.body.classList.remove("state-on");
        document.body.classList.remove("state-off");
        return;
    }
    
    document.body.classList.toggle("state-on", enabled);
    document.body.classList.toggle("state-off", !enabled);
}

function openPreferences() {
    const message = { type: "open-preferences" };
    webkit.messageHandlers.controller.postMessage(JSON.stringify(message));
}

function openLinkInBrowser(event) {
    event.preventDefault();
    
    const message = { type: "open-url", url: event.target.href };
    webkit.messageHandlers.controller.postMessage(JSON.stringify(message));
}

openPreferencesSelector.addEventListener("click", openPreferences);
supportLinkSelector.addEventListener("click", openLinkInBrowser);
downloadLinkSelector.addEventListener("click", openLinkInBrowser);

