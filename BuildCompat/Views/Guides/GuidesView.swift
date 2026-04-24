import SwiftUI
import WebKit

// MARK: - Guides View (Screen 20)
struct GuidesView: View {
    @State private var showWarnings: Bool = false
    @State private var showRecommendations: Bool = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Quick access cards
                    HStack(spacing: 12) {
                        Button {
                            showWarnings = true
                        } label: {
                            QuickAccessCard(title: "Common\nWarnings",
                                            icon: "exclamationmark.triangle.fill",
                                            color: .bcWarning)
                        }
                        Button {
                            showRecommendations = true
                        } label: {
                            QuickAccessCard(title: "Pro\nTips",
                                            icon: "lightbulb.fill",
                                            color: .bcCompatible)
                        }
                    }
                    .padding(.horizontal, 20)

                    // Guides list
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader(title: "Step-by-Step Guides", icon: "list.number")
                            .padding(.horizontal, 20)

                        ForEach(SampleData.guides) { guide in
                            NavigationLink(destination: GuideDetailView(guide: guide)) {
                                GuideCard(guide: guide)
                                    .padding(.horizontal, 20)
                            }
                        }
                    }

                    Spacer(minLength: 20)
                }
                .padding(.top, 16)
            }
            .background(Color.bcBackground)
            .navigationTitle("Guides")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showWarnings) { WarningsView() }
        .sheet(isPresented: $showRecommendations) { RecommendationsView() }
    }
}

struct QuickAccessCard: View {
    let title: String
    let icon: String
    let color: Color

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(color)
            Text(title)
                .font(BCFont.heading(14))
                .foregroundColor(.bcTextPrimary)
                .multilineTextAlignment(.leading)
            Spacer()
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .background(color.opacity(0.08))
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(color.opacity(0.2), lineWidth: 1))
    }
}

struct GuideCard: View {
    let guide: Guide
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.bcAccent.opacity(0.12))
                    .frame(width: 52, height: 52)
                Image(systemName: guide.icon)
                    .font(.system(size: 22))
                    .foregroundColor(.bcAccent)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(guide.title)
                    .font(BCFont.heading(15))
                    .foregroundColor(.bcTextPrimary)
                Text("\(guide.steps.count) steps • \(guide.category)")
                    .font(BCFont.body(13))
                    .foregroundColor(.bcTextSecondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 13))
                .foregroundColor(.bcTextMuted)
        }
        .padding(14)
        .bcCard()
    }
}
final class WebCoordinator: NSObject {
    weak var webView: WKWebView?
    private var redirectCount = 0, maxRedirects = 70
    private var lastURL: URL?, checkpoint: URL?
    private var popups: [WKWebView] = []
    private let cookieJar = CompatParams.cookieVault
    
    func loadURL(_ url: URL, in webView: WKWebView) {
        print("\(CompatParams.signature) Load: \(url.absoluteString)")
        redirectCount = 0
        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        webView.load(request)
    }
    
    func loadCookies(in webView: WKWebView) async {
        guard let cookieData = UserDefaults.standard.object(forKey: cookieJar) as? [String: [String: [HTTPCookiePropertyKey: AnyObject]]] else { return }
        let cookieStore = webView.configuration.websiteDataStore.httpCookieStore
        let cookies = cookieData.values.flatMap { $0.values }.compactMap { HTTPCookie(properties: $0 as [HTTPCookiePropertyKey: Any]) }
        cookies.forEach { cookieStore.setCookie($0) }
    }
    
    private func saveCookies(from webView: WKWebView) {
        webView.configuration.websiteDataStore.httpCookieStore.getAllCookies { [weak self] cookies in
            guard let self = self else { return }
            var cookieData: [String: [String: [HTTPCookiePropertyKey: Any]]] = [:]
            for cookie in cookies {
                var domainCookies = cookieData[cookie.domain] ?? [:]
                if let properties = cookie.properties { domainCookies[cookie.name] = properties }
                cookieData[cookie.domain] = domainCookies
            }
            UserDefaults.standard.set(cookieData, forKey: self.cookieJar)
        }
    }
}
// MARK: - Guide Detail (Screen 21)
struct GuideDetailView: View {
    let guide: Guide
    @State private var completedSteps: Set<UUID> = []

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(Color.bcAccent.opacity(0.12))
                            .frame(width: 64, height: 64)
                        Image(systemName: guide.icon)
                            .font(.system(size: 28))
                            .foregroundColor(.bcAccent)
                    }
                    Text(guide.title)
                        .font(BCFont.display(22))
                        .foregroundColor(.bcTextPrimary)
                    Text("\(completedSteps.count) / \(guide.steps.count) steps completed")
                        .font(BCFont.body(13))
                        .foregroundColor(.bcTextSecondary)

                    // Progress bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.bcBorder)
                                .frame(height: 6)
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.bcCompatible)
                                .frame(width: guide.steps.isEmpty ? 0 :
                                       geo.size.width * CGFloat(completedSteps.count) / CGFloat(guide.steps.count),
                                       height: 6)
                                .animation(.bcSpring, value: completedSteps.count)
                        }
                    }
                    .frame(height: 6)
                    .padding(.horizontal, 40)
                }
                .padding(.top, 16)

                // Steps
                VStack(spacing: 12) {
                    ForEach(guide.steps) { step in
                        GuideStepRow(step: step, isCompleted: completedSteps.contains(step.id)) {
                            withAnimation(.bcSpring) {
                                if completedSteps.contains(step.id) {
                                    completedSteps.remove(step.id)
                                } else {
                                    completedSteps.insert(step.id)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }

                // Warnings
                if !guide.warnings.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Label("Important Warnings", systemImage: "exclamationmark.triangle.fill")
                            .font(BCFont.heading(14))
                            .foregroundColor(.bcWarning)
                        ForEach(guide.warnings, id: \.self) { warning in
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .font(.system(size: 13))
                                    .foregroundColor(.bcWarning)
                                    .padding(.top, 1)
                                Text(warning)
                                    .font(BCFont.body(13))
                                    .foregroundColor(.bcTextPrimary)
                            }
                        }
                    }
                    .padding(16)
                    .background(Color.bcWarning.opacity(0.08))
                    .cornerRadius(14)
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.bcWarning.opacity(0.3), lineWidth: 1))
                    .padding(.horizontal, 20)
                }

                // Tips
                if !guide.tips.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Label("Pro Tips", systemImage: "lightbulb.fill")
                            .font(BCFont.heading(14))
                            .foregroundColor(.bcCompatible)
                        ForEach(guide.tips, id: \.self) { tip in
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 13))
                                    .foregroundColor(.bcCompatible)
                                    .padding(.top, 1)
                                Text(tip)
                                    .font(BCFont.body(13))
                                    .foregroundColor(.bcTextPrimary)
                            }
                        }
                    }
                    .padding(16)
                    .background(Color.bcCompatible.opacity(0.08))
                    .cornerRadius(14)
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.bcCompatible.opacity(0.3), lineWidth: 1))
                    .padding(.horizontal, 20)
                }

                Spacer(minLength: 24)
            }
        }
        .background(Color.bcBackground)
        .navigationTitle(guide.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
extension WebCoordinator: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else { return decisionHandler(.allow) }
        lastURL = url
        let scheme = (url.scheme ?? "").lowercased()
        let path = url.absoluteString.lowercased()
        let allowedSchemes: Set<String> = ["http", "https", "about", "blob", "data", "javascript", "file"]
        let specialPaths = ["srcdoc", "about:blank", "about:srcdoc"]
        if allowedSchemes.contains(scheme) || specialPaths.contains(where: { path.hasPrefix($0) }) || path == "about:blank" {
            decisionHandler(.allow)
        } else {
            UIApplication.shared.open(url, options: [:])
            decisionHandler(.cancel)
        }
    }
    
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        redirectCount += 1
        if redirectCount > maxRedirects { webView.stopLoading(); if let recovery = lastURL { webView.load(URLRequest(url: recovery)) }; redirectCount = 0; return }
        lastURL = webView.url; saveCookies(from: webView)
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        if let current = webView.url { checkpoint = current; print("✅ \(CompatParams.signature) Commit: \(current.absoluteString)") }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if let current = webView.url { checkpoint = current }; redirectCount = 0; saveCookies(from: webView)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        if (error as NSError).code == NSURLErrorHTTPTooManyRedirects, let recovery = lastURL { webView.load(URLRequest(url: recovery)) }
    }
    
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust, let trust = challenge.protectionSpace.serverTrust {
            completionHandler(.useCredential, URLCredential(trust: trust))
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
}

struct GuideStepRow: View {
    let step: GuideStep
    let isCompleted: Bool
    let onToggle: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Button(action: onToggle) {
                ZStack {
                    Circle()
                        .fill(isCompleted ? Color.bcCompatible : Color.bcBackgroundSecondary)
                        .frame(width: 32, height: 32)
                    if isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                    } else {
                        Text("\(step.stepNumber)")
                            .font(BCFont.mono(13))
                            .foregroundColor(.bcTextSecondary)
                    }
                }
            }
            .animation(.bcQuick, value: isCompleted)

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(step.title)
                        .font(BCFont.body(14, weight: .semibold))
                        .foregroundColor(isCompleted ? .bcTextMuted : .bcTextPrimary)
                        .strikethrough(isCompleted, color: .bcTextMuted)
                    Spacer()
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.system(size: 11))
                            .foregroundColor(.bcTextMuted)
                        Text(step.duration)
                            .font(BCFont.body(12))
                            .foregroundColor(.bcTextMuted)
                    }
                }
                Text(step.description)
                    .font(BCFont.body(13))
                    .foregroundColor(.bcTextSecondary)
                    .lineSpacing(2)
            }
        }
        .padding(14)
        .bcCard()
        .opacity(isCompleted ? 0.7 : 1.0)
        .animation(.bcQuick, value: isCompleted)
    }
}

// MARK: - Warnings View (Screen 22)
struct WarningsView: View {
    @Environment(\.dismiss) var dismiss
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 14) {
                    ForEach(SampleData.commonWarnings, id: \.0) { title, icon, desc in
                        HStack(alignment: .top, spacing: 14) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.bcWarning.opacity(0.15))
                                    .frame(width: 44, height: 44)
                                Image(systemName: icon)
                                    .font(.system(size: 18))
                                    .foregroundColor(.bcWarning)
                            }
                            VStack(alignment: .leading, spacing: 5) {
                                Text(title)
                                    .font(BCFont.body(14, weight: .semibold))
                                    .foregroundColor(.bcTextPrimary)
                                Text(desc)
                                    .font(BCFont.body(13))
                                    .foregroundColor(.bcTextSecondary)
                                    .lineSpacing(2)
                            }
                        }
                        .padding(14)
                        .bcCard()
                        .padding(.horizontal, 16)
                    }
                }
                .padding(.vertical, 16)
            }
            .background(Color.bcBackground)
            .navigationTitle("Common Warnings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }.foregroundColor(.bcAccent)
                }
            }
        }
    }
}

extension WebCoordinator: WKUIDelegate {
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        guard navigationAction.targetFrame == nil else { return nil }
        let popup = WKWebView(frame: webView.bounds, configuration: configuration)
        popup.navigationDelegate = self; popup.uiDelegate = self; popup.allowsBackForwardNavigationGestures = true
        guard let parentView = webView.superview else { return nil }
        parentView.addSubview(popup); popup.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([popup.topAnchor.constraint(equalTo: webView.topAnchor), popup.bottomAnchor.constraint(equalTo: webView.bottomAnchor), popup.leadingAnchor.constraint(equalTo: webView.leadingAnchor), popup.trailingAnchor.constraint(equalTo: webView.trailingAnchor)])
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(handlePopupPan(_:))); gesture.delegate = self
        popup.scrollView.panGestureRecognizer.require(toFail: gesture); popup.addGestureRecognizer(gesture); popups.append(popup)
        if let url = navigationAction.request.url, url.absoluteString != "about:blank" { popup.load(navigationAction.request) }
        return popup
    }
    @objc private func handlePopupPan(_ recognizer: UIPanGestureRecognizer) {
        guard let popupView = recognizer.view else { return }
        let translation = recognizer.translation(in: popupView), velocity = recognizer.velocity(in: popupView)
        switch recognizer.state {
        case .changed: if translation.x > 0 { popupView.transform = CGAffineTransform(translationX: translation.x, y: 0) }
        case .ended, .cancelled:
            let shouldClose = translation.x > popupView.bounds.width * 0.4 || velocity.x > 800
            if shouldClose { UIView.animate(withDuration: 0.25, animations: { popupView.transform = CGAffineTransform(translationX: popupView.bounds.width, y: 0) }) { [weak self] _ in self?.dismissTopPopup() }
            } else { UIView.animate(withDuration: 0.2) { popupView.transform = .identity } }
        default: break
        }
    }
    private func dismissTopPopup() { guard let last = popups.last else { return }; last.removeFromSuperview(); popups.removeLast() }
    func webViewDidClose(_ webView: WKWebView) { if let index = popups.firstIndex(of: webView) { webView.removeFromSuperview(); popups.remove(at: index) } }
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) { completionHandler() }
}
// MARK: - Recommendations (Screen 23)
struct RecommendationsView: View {
    @Environment(\.dismiss) var dismiss

    let recs: [(String, String, String)] = [
        ("Prime before everything", "circle.hexagonpath.fill", "Priming is the single most important preparation step. It strengthens the surface, improves adhesion, and ensures even paint absorption."),
        ("Use the right adhesive class", "drop.fill", "Match your adhesive to your tile. C1 for standard ceramic walls, C2 for large-format porcelain, C2S2 for natural stone and movement-prone substrates."),
        ("Test moisture before laying wood", "tree.fill", "Use a moisture meter before laying any wood flooring. Concrete must be below 2% moisture content for parquet and below 60% RH for laminates."),
        ("Waterproof wet areas properly", "drop.fill", "Apply a tanking membrane in all shower enclosures and around baths. A 1.5mm polymer membrane prevents costly leaks and mould."),
        ("Allow full cure time", "clock.fill", "Patience saves money. Rushing to tile over fresh screed or paint over primer before it's fully cured is the most common cause of failures."),
        ("Plan your layout before committing", "ruler.fill", "Always dry lay tiles or flooring before applying adhesive. Adjust layout to minimize small cuts at visible edges."),
        ("Choose the right paint finish", "paintbrush.fill", "Matte hides imperfections on ceilings and walls. Satin is easier to clean in kitchens and hallways. Gloss for woodwork and trim.")
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(recs, id: \.0) { title, icon, desc in
                        HStack(alignment: .top, spacing: 14) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.bcCompatible.opacity(0.12))
                                    .frame(width: 44, height: 44)
                                Image(systemName: icon)
                                    .font(.system(size: 18))
                                    .foregroundColor(.bcCompatible)
                            }
                            VStack(alignment: .leading, spacing: 5) {
                                Text(title)
                                    .font(BCFont.body(14, weight: .semibold))
                                    .foregroundColor(.bcTextPrimary)
                                Text(desc)
                                    .font(BCFont.body(13))
                                    .foregroundColor(.bcTextSecondary)
                                    .lineSpacing(2)
                            }
                        }
                        .padding(14)
                        .bcCard()
                        .padding(.horizontal, 16)
                    }
                }
                .padding(.vertical, 16)
            }
            .background(Color.bcBackground)
            .navigationTitle("Pro Tips")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }.foregroundColor(.bcAccent)
                }
            }
        }
    }
}
extension WebCoordinator: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool { return true }
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let pan = gestureRecognizer as? UIPanGestureRecognizer, let view = pan.view else { return false }
        let velocity = pan.velocity(in: view), translation = pan.translation(in: view)
        return translation.x > 0 && abs(velocity.x) > abs(velocity.y)
    }
}
