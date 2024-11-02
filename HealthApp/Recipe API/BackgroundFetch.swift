import BackgroundTasks

class BackgroundFetchService {
    
    // Schedule the background fetch task
    func scheduleRecipeFetch() {
        let request = BGAppRefreshTaskRequest(identifier: "com.myApp.recipefetch")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60) // 15 minutes from now
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Failed to schedule background fetch: \(error)")
        }
    }

    // Handle the background fetch task
    func handleRecipeFetchTask(task: BGAppRefreshTask) {
        // Re-schedule the task for future executions before the current one completes
        scheduleRecipeFetch()  // Renamed correctly

        let recipeService = RecipeService()

        recipeService.startFetching { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("Background recipe fetching completed successfully.")
                    task.setTaskCompleted(success: true)  // Indicate successful completion
                case .failure(let error):
                    print("Background fetch failed: \(error.localizedDescription)")
                    task.setTaskCompleted(success: false)  // Indicate failure
                }
            }
        }

        // Handle expiration, i.e., when the system terminates the task due to time constraints
        task.expirationHandler = {
            print("Background fetch task expired.")
            task.setTaskCompleted(success: false)
        }
    }
}
