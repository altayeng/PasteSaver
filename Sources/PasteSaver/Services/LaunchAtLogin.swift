import Foundation
import ServiceManagement

enum LaunchAtLogin {
    private static let configuredKey = "hasConfiguredLaunchAtLogin"

    static var isEnabled: Bool {
        SMAppService.mainApp.status == .enabled
    }

    static func setEnabled(_ enabled: Bool) throws {
        if enabled {
            try SMAppService.mainApp.register()
        } else {
            try SMAppService.mainApp.unregister()
        }
    }

    static func registerOnFirstRun(defaults: UserDefaults = .standard) {
        guard !defaults.bool(forKey: configuredKey) else { return }
        do {
            try setEnabled(true)
            defaults.set(true, forKey: configuredKey)
        } catch {
            // Registration only works from a bundled app; retry on the next launch.
        }
    }
}
