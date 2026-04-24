import SwiftUI
import Combine
import Network

struct SplashView: View {
    @State private var logoScale: CGFloat = 0.5
    @State private var logoOpacity: Double = 0
    @State private var textOpacity: Double = 0
    @State private var subtitleOpacity: Double = 0
    @State private var layersOffset: [CGFloat] = [-40, -20, 0, 20, 40]
    @State private var layersOpacity: [Double] = [0, 0, 0, 0, 0]
    @StateObject private var viewModel = BuildCompatViewModel()
    @State private var networkMonitor = NWPathMonitor()
    @State private var cancellables = Set<AnyCancellable>()
    @State private var particlesVisible: Bool = false
    
    let layerColors: [Color] = [.bcConcrete, .bcWood, .bcTile, .bcPaint, .bcAccent]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    colors: [Color(hex: "#EEF2F6"), Color(hex: "#F5F7FA")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                GeometryReader { geometry in
                    Image("p")
                        .resizable().scaledToFill()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .ignoresSafeArea()
                        .blur(radius: 20)
                        .opacity(0.4)
                }
                .ignoresSafeArea()
                
                NavigationLink(
                    destination: BuildCompatWebView().navigationBarHidden(true),
                    isActive: $viewModel.navigateToWeb
                ) { EmptyView() }
                
                NavigationLink(
                    destination: RootView().navigationBarBackButtonHidden(true),
                    isActive: $viewModel.navigateToMain
                ) { EmptyView() }
                
                // Particles
                if particlesVisible {
                    ForEach(0..<12, id: \.self) { i in
                        Circle()
                            .fill(layerColors[i % layerColors.count].opacity(0.3))
                            .frame(width: CGFloat.random(in: 4...12))
                            .offset(
                                x: CGFloat.random(in: -160...160),
                                y: CGFloat.random(in: -260...260)
                            )
                            .animation(
                                Animation.easeInOut(duration: Double.random(in: 1.5...3.0))
                                    .repeatForever(autoreverses: true)
                                    .delay(Double(i) * 0.1),
                                value: particlesVisible
                            )
                    }
                }
                
                VStack(spacing: 24) {
                    // Logo - stacked material layers
                    ZStack {
                        ForEach(0..<5, id: \.self) { i in
                            RoundedRectangle(cornerRadius: 12)
                                .fill(layerColors[i].opacity(0.85))
                                .frame(width: 80 - CGFloat(i) * 8, height: 16)
                                .offset(y: layersOffset[i])
                                .opacity(layersOpacity[i])
                                .shadow(color: layerColors[i].opacity(0.3), radius: 8, y: 4)
                        }
                    }
                    .frame(width: 100, height: 100)
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)
                    
                    // App name
                    VStack(spacing: 6) {
                        Text("BuildCompat")
                            .font(BCFont.display(34))
                            .foregroundColor(.bcTextPrimary)
                            .opacity(textOpacity)
                        
                        Text("Match materials correctly")
                            .font(BCFont.body(15, weight: .medium))
                            .foregroundColor(.bcTextSecondary)
                            .opacity(subtitleOpacity)
                    }
                    
                    ProgressView().tint(.bcBackground)
                }
            }
            .fullScreenCover(isPresented: $viewModel.showPermissionPrompt) {
                BuildCompatConsentView(viewModel: viewModel)
            }
            .fullScreenCover(isPresented: $viewModel.showOfflineView) {
                OfflineView()
            }
            .onAppear {
                setupStreams()
                setupNetworkMonitoring()
                runAnimation()
                viewModel.launch()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func setupStreams() {
        NotificationCenter.default.publisher(for: Notification.Name("ConversionDataReceived"))
            .compactMap { $0.userInfo?["conversionData"] as? [String: Any] }
            .sink { data in
                viewModel.ingestAttribution(data)
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: Notification.Name("deeplink_values"))
            .compactMap { $0.userInfo?["deeplinksData"] as? [String: Any] }
            .sink { data in
                viewModel.ingestRoutes(data)
            }
            .store(in: &cancellables)
    }
    
    func runAnimation() {
        // Logo scale/fade in
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2)) {
            logoScale = 1.0
            logoOpacity = 1.0
        }
        // Layers animate in one by one
        for i in 0..<5 {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.4 + Double(i) * 0.1)) {
                layersOffset[i] = CGFloat(i - 2) * 18
                layersOpacity[i] = 1.0
            }
        }
        // Text
        withAnimation(.easeOut(duration: 0.5).delay(0.9)) {
            textOpacity = 1.0
        }
        withAnimation(.easeOut(duration: 0.5).delay(1.1)) {
            subtitleOpacity = 1.0
        }
        // Particles
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
            particlesVisible = true
        }
    }
    
    private func setupNetworkMonitoring() {
        networkMonitor.pathUpdateHandler = { path in
            Task { @MainActor in
                viewModel.connectivityChanged(path.status == .satisfied)
            }
        }
        networkMonitor.start(queue: .global(qos: .background))
    }
    
}

#Preview {
    BuildCompatConsentView(viewModel: BuildCompatViewModel())
}


