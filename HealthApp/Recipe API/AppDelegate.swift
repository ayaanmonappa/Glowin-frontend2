import UIKit
import BackgroundTasks
import UserNotifications


class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Set UNUserNotificationCenter delegate
        UNUserNotificationCenter.current().delegate = self
        
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.myApp.recipefetch", using: nil) { task in
            self.handleRecipeFetchTask(task: task as! BGAppRefreshTask)
        }
        
        // Request notification permissions
        requestNotificationPermission()
        
        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        scheduleRecipeFetch()
        print("App entered background, background fetch scheduled.")
    }

    func requestNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permissions granted.")
            } else {
                if let error = error {
                    print("Notification permissions denied: \(error.localizedDescription)")
                } else {
                    print("Notification permissions denied by the user.")
                }
            }
        }
        
        // Check the current notification settings
        center.getNotificationSettings { settings in
            print("Notification settings: \(settings)")
        }
    }

    // Schedule background fetch
    func scheduleRecipeFetch() {
        let request = BGAppRefreshTaskRequest(identifier: "com.myApp.recipefetch")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60)  // Fetch after 15 minutes
        do {
            try BGTaskScheduler.shared.submit(request)
            print("Background fetch task scheduled.")
        } catch {
            print("Failed to schedule background fetch: \(error)")
        }
    }

    // Handle background fetch task
    func handleRecipeFetchTask(task: BGAppRefreshTask) {
        scheduleRecipeFetch()  // Re-schedule for future execution
        print("Handling background fetch task.")

        let recipeService = RecipeService()
        recipeService.startFetching { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("Background recipe fetching completed successfully.")
                    task.setTaskCompleted(success: true)
                    // Schedule a notification when fetch is complete
                    self.scheduleNotification(title: "Recipe Fetch Complete", body: "Your recipes are ready!")
                case .failure(let error):
                    print("Background recipe fetching failed: \(error.localizedDescription)")
                    task.setTaskCompleted(success: false)
                }
            }
        }

        task.expirationHandler = {
            print("Background fetch task expired.")
            task.setTaskCompleted(success: false)
        }
    }

    // Schedule a local notification
    func scheduleNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        print("Attempting to schedule notification: \(title), \(body)")

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error.localizedDescription)")
            } else {
                print("Notification successfully scheduled: \(title)")
            }
        }
    }

    // Show notifications even when the app is in the foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("Foreground notification: \(notification.request.content.title)")
        // Ensure the notification is displayed as a banner and plays sound even when the app is in the foreground
        completionHandler([.banner, .sound])
    }
}
