import Foundation
import LocalAuthentication

@Observable
final class AutoLockService {
    private var lastActivity = Date()
    private var lastAuth: Date?
    private var timer: Timer?

    var autoLockMinutes: Int {
        UserDefaults.standard.integer(forKey: "autoLockMinutes")
    }

    func registerActivity() {
        lastActivity = Date()
    }

    func startMonitoring() {
        timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            self?.checkLock()
        }
    }

    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }

    private func checkLock() {
        let minutes = autoLockMinutes
        guard minutes > 0 else { return }

        let cooldown = lastAuth.flatMap { -$0.timeIntervalSinceNow } ?? Double.greatestFiniteMagnitude
        guard cooldown > Double(minutes) * 60 else { return }

        let elapsed = -lastActivity.timeIntervalSinceNow
        if elapsed > Double(minutes) * 60 {
            authenticate()
        }
    }

    private func authenticate() {
        let context = LAContext()
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else { return }
        context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "Unlock API Matrix") { success, _ in
            if success {
                DispatchQueue.main.async {
                    self.lastActivity = Date()
                    self.lastAuth = Date()
                }
            }
        }
    }
}
