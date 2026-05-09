import LocalAuthentication
import SwiftUI

struct AppRootView: View {
    @AppStorage("appLanguage") private var appLanguageRaw = AppLanguage.system.rawValue
    @AppStorage("privacyLockEnabled") private var privacyLockEnabled = false
    @Environment(\.scenePhase) private var scenePhase
    @State private var isUnlocked = false
    @State private var unlockError: String?
    @State private var showLaunchSplash = true
    @State private var didScheduleLaunchSplash = false

    private var language: AppLanguage {
        AppLanguage(rawValue: appLanguageRaw) ?? .system
    }

    var body: some View {
        ZStack {
            mainTabs
                .blur(radius: privacyLockEnabled && !isUnlocked ? 16 : 0)

            if privacyLockEnabled && !isUnlocked {
                PrivacyLockView(
                    language: language,
                    errorMessage: unlockError,
                    onUnlock: authenticate
                )
            }

            if showLaunchSplash {
                LaunchSplashView(language: language)
                    .transition(.opacity)
                    .zIndex(2)
            }
        }
        .tint(AppTheme.teal)
        .preferredColorScheme(.dark)
        .onAppear {
            scheduleLaunchSplash()
            if privacyLockEnabled {
                authenticate()
            }
        }
        .onChange(of: privacyLockEnabled) { _, isEnabled in
            isUnlocked = !isEnabled
            if isEnabled {
                authenticate()
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if privacyLockEnabled && newPhase != .active {
                isUnlocked = false
            }
            if privacyLockEnabled && newPhase == .active && !isUnlocked {
                authenticate()
            }
        }
    }

    private func scheduleLaunchSplash() {
        guard !didScheduleLaunchSplash else { return }
        didScheduleLaunchSplash = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.35) {
            withAnimation(.easeInOut(duration: 0.38)) {
                showLaunchSplash = false
            }
        }
    }

    private var mainTabs: some View {
        TabView {
            JournalView(language: language)
                .tabItem {
                    Label(L10n.t(.journal, language), systemImage: "book.closed")
                }

            MemoriesView(language: language)
                .tabItem {
                    Label(L10n.t(.memories, language), systemImage: "sparkles")
                }

            SearchView(language: language)
                .tabItem {
                    Label(L10n.t(.search, language), systemImage: "magnifyingglass")
                }

            LibraryView(language: language)
                .tabItem {
                    Label(L10n.t(.library, language), systemImage: "square.grid.2x2")
                }

            SettingsView(language: language)
                .tabItem {
                    Label(L10n.t(.settings, language), systemImage: "gearshape")
                }
        }
    }

    private func authenticate() {
        let context = LAContext()
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            unlockError = L10n.t(.privacyLockFailed, language)
            return
        }

        context.evaluatePolicy(
            .deviceOwnerAuthentication,
            localizedReason: L10n.t(.unlockJournal, language)
        ) { success, _ in
            DispatchQueue.main.async {
                isUnlocked = success
                unlockError = success ? nil : L10n.t(.privacyLockFailed, language)
            }
        }
    }
}

private struct LaunchSplashView: View {
    let language: AppLanguage
    @State private var isAnimating = false

    private let stars: [(x: CGFloat, y: CGFloat, size: CGFloat, delay: Double)] = [
        (0.16, 0.16, 3, 0.0),
        (0.78, 0.14, 2, 0.2),
        (0.88, 0.28, 4, 0.1),
        (0.24, 0.36, 2, 0.4),
        (0.68, 0.42, 3, 0.3),
        (0.36, 0.72, 2, 0.15),
        (0.84, 0.76, 3, 0.35)
    ]

    var body: some View {
        ZStack {
            Image("SplashIcon")
                .resizable()
                .scaledToFill()
                .scaleEffect(isAnimating ? 1.05 : 1)
                .blur(radius: 2)
                .overlay(Color.black.opacity(0.46))
                .ignoresSafeArea()

            AppTheme.background
                .opacity(0.58)
                .ignoresSafeArea()

            GeometryReader { proxy in
                ForEach(stars.indices, id: \.self) { index in
                    let star = stars[index]
                    Circle()
                        .fill(.white.opacity(isAnimating ? 0.86 : 0.25))
                        .frame(width: star.size, height: star.size)
                        .position(
                            x: proxy.size.width * star.x,
                            y: proxy.size.height * star.y + (isAnimating ? -8 : 8)
                        )
                        .animation(
                            .easeInOut(duration: 1.0)
                                .delay(star.delay)
                                .repeatForever(autoreverses: true),
                            value: isAnimating
                        )
                }
            }

            VStack(spacing: 18) {
                Image("SplashIcon")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 132, height: 132)
                    .clipShape(RoundedRectangle(cornerRadius: 28))
                    .overlay(
                        RoundedRectangle(cornerRadius: 28)
                            .stroke(.white.opacity(0.20), lineWidth: 1)
                    )
                    .shadow(color: AppTheme.gold.opacity(0.28), radius: 26, x: 0, y: 14)
                    .scaleEffect(isAnimating ? 1 : 0.90)
                    .opacity(isAnimating ? 1 : 0)

                VStack(spacing: 8) {
                    Text("MemoryJournal")
                        .font(.title.weight(.semibold))
                        .foregroundStyle(AppTheme.textPrimary)

                    Text(L10n.t(.memoriesHeroSubtitle, language))
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .offset(y: isAnimating ? 0 : 12)
                .opacity(isAnimating ? 1 : 0)
            }
            .padding(30)
        }
        .onAppear {
            withAnimation(.spring(response: 0.75, dampingFraction: 0.82)) {
                isAnimating = true
            }
        }
    }
}

private struct PrivacyLockView: View {
    let language: AppLanguage
    let errorMessage: String?
    let onUnlock: () -> Void

    var body: some View {
        AppPageContainer {
            VStack(spacing: 18) {
                Image(systemName: "lock.shield")
                    .font(.system(size: 48, weight: .semibold))
                    .foregroundStyle(AppTheme.teal)

                Text(L10n.t(.privacyLock, language))
                    .font(.title.weight(.semibold))
                    .foregroundStyle(AppTheme.textPrimary)

                Button {
                    onUnlock()
                } label: {
                    Label(L10n.t(.unlockJournal, language), systemImage: "faceid")
                        .frame(maxWidth: 260)
                }
                .buttonStyle(.borderedProminent)
                .tint(AppTheme.teal)

                if let errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(.red.opacity(0.85))
                }
            }
            .padding(24)
        }
    }
}
