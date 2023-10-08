import SwiftUI
import FirebaseCore

class AppDelegate: UIResponder, UIApplicationDelegate {
        
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Firebase 설정
        guard let filePath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
              let options = FirebaseOptions(contentsOfFile: filePath)
        else { return true }
        
        FirebaseApp.configure(options: options)
        
        return true
    }
}

@main
struct ZenoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var userViewModel = UserViewModel()
    @StateObject private var commViewModel = CommViewModel()
   // @StateObject var router = Router<Path>(root: .A)
    var body: some Scene {
        WindowGroup {
            InitialView()
                .environmentObject(userViewModel)
                .environmentObject(commViewModel)
                .environmentObject(Router<Path>(root: .A))
                .onChange(of: userViewModel.currentUser) { newValue in
                    commViewModel.updateCurrentUser(user: newValue)
                }
        }
    }
}
