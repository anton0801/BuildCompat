import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var appState: AppState
    @State private var currentPage: Int = 0
    @State private var dragOffset: CGFloat = 0

    let pages: [OnboardingPage] = [
        OnboardingPage(
            title: "Choose materials\ncorrectly",
            subtitle: "Select from a library of paints, tiles, wood, concrete, adhesives and more",
            icon: "square.3.layers.3d.down.right.fill",
            color: Color.bcAccent,
            accent: Color.bcTile
        ),
        OnboardingPage(
            title: "Avoid repair\nmistakes",
            subtitle: "Get instant warnings before combining incompatible materials that could ruin your renovation",
            icon: "exclamationmark.shield.fill",
            color: Color.bcWarning,
            accent: Color.bcPaint
        ),
        OnboardingPage(
            title: "Check compatibility\ninstantly",
            subtitle: "Two taps — and you know exactly if your materials work together, with step-by-step fixes",
            icon: "checkmark.seal.fill",
            color: Color.bcCompatible,
            accent: Color.bcWood
        )
    ]

    var body: some View {
        ZStack {
            Color.bcBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // Skip button
                HStack {
                    Spacer()
                    Button("Skip") {
                        withAnimation(.bcSpring) { appState.hasCompletedOnboarding = true }
                    }
                    .font(BCFont.body(15, weight: .medium))
                    .foregroundColor(.bcTextSecondary)
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                }

                // Page content
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { i in
                        OnboardingPageView(page: pages[i], isActive: currentPage == i)
                            .tag(i)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.bcSpring, value: currentPage)

                // Dots + Button
                VStack(spacing: 32) {
                    HStack(spacing: 8) {
                        ForEach(0..<pages.count, id: \.self) { i in
                            Capsule()
                                .fill(i == currentPage ? Color.bcAccent : Color.bcBorder)
                                .frame(width: i == currentPage ? 24 : 8, height: 8)
                                .animation(.bcSpring, value: currentPage)
                        }
                    }

                    Button {
                        if currentPage < pages.count - 1 {
                            withAnimation(.bcSpring) { currentPage += 1 }
                        } else {
                            withAnimation(.bcSpring) { appState.hasCompletedOnboarding = true }
                        }
                    } label: {
                        HStack {
                            Text(currentPage < pages.count - 1 ? "Next" : "Get Started")
                            Image(systemName: "arrow.right")
                        }
                    }
                    .buttonStyle(BCPrimaryButtonStyle())
                    .padding(.horizontal, 24)
                }
                .padding(.bottom, 48)
            }
        }
    }
}

struct OnboardingPage {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let accent: Color
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    let isActive: Bool
    @State private var illustrationScale: CGFloat = 0.8
    @State private var illustrationOpacity: Double = 0
    @State private var textOffset: CGFloat = 20
    @State private var textOpacity: Double = 0
    @State private var pulseScale: CGFloat = 1.0

    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            // Illustration
            ZStack {
                Circle()
                    .fill(page.color.opacity(0.08))
                    .frame(width: 200, height: 200)
                    .scaleEffect(pulseScale)

                Circle()
                    .fill(page.color.opacity(0.12))
                    .frame(width: 160, height: 160)

                Circle()
                    .fill(page.color.opacity(0.15))
                    .frame(width: 120, height: 120)

                Image(systemName: page.icon)
                    .font(.system(size: 56, weight: .medium))
                    .foregroundColor(page.color)
                    .symbolRenderingMode(.hierarchical)

                // Floating accent dots
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .fill(page.accent.opacity(0.7))
                        .frame(width: 10, height: 10)
                        .offset(
                            x: cos(Double(i) * 2.094) * 80,
                            y: sin(Double(i) * 2.094) * 80
                        )
                }
            }
            .scaleEffect(illustrationScale)
            .opacity(illustrationOpacity)

            // Text
            VStack(spacing: 12) {
                Text(page.title)
                    .font(BCFont.display(30))
                    .foregroundColor(.bcTextPrimary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)

                Text(page.subtitle)
                    .font(BCFont.body(16))
                    .foregroundColor(.bcTextSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 32)
            }
            .offset(y: textOffset)
            .opacity(textOpacity)

            Spacer()
        }
        .onChange(of: isActive) { active in
            if active { animate() }
        }
        .onAppear { if isActive { animate() } }
    }

    func animate() {
        illustrationScale = 0.8
        illustrationOpacity = 0
        textOffset = 20
        textOpacity = 0

        withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1)) {
            illustrationScale = 1.0
            illustrationOpacity = 1.0
        }
        withAnimation(.easeOut(duration: 0.5).delay(0.25)) {
            textOffset = 0
            textOpacity = 1.0
        }
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            pulseScale = 1.06
        }
    }
}
