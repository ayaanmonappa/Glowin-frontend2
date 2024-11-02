import SwiftUI

@main
struct HealthAppApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate  // Bridge to AppDelegate
    
    var body: some Scene {
        WindowGroup {
            OpeningPage()
                .onOpenURL { url in
                    handleURL(url)
                }
        }
    }
    
    
    
    func handleURL(_ url: URL) {
        // Parse the URL and navigate to the appropriate part of the app
        if url.absoluteString == "glowinapp://reset-success" {
            // Handle successful password reset navigation
        } else if url.absoluteString == "glowinapp://verify-success" {
            // Handle successful email verification navigation
        }
    }
    
}
