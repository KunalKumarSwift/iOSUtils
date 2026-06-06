/// Read-only device and app metadata helpers.
///
/// All properties are static and read from system APIs at call time.
/// Does not use the Facade pattern because there is no swappable backend.
/// No environment variables are consumed here.
#if canImport(UIKit)
import UIKit

/// Static accessors for hardware, OS, and app metadata.
public struct DeviceInfo {

    /// The raw hardware model identifier (e.g. `"iPhone15,2"`).
    public static var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        return machineMirror.children.compactMap { $0.value as? Int8 }.filter { $0 != 0 }.map { String(UnicodeScalar(UInt8($0))) }.joined()
    }

    /// The OS version string reported by `UIDevice` (e.g. `"17.0"`).
    public static var systemVersion: String { UIDevice.current.systemVersion }

    /// The OS name reported by `UIDevice` (e.g. `"iOS"`).
    public static var systemName: String { UIDevice.current.systemName }

    /// The user-assigned name of the device (e.g. `"Kunal's iPhone"`).
    public static var deviceName: String { UIDevice.current.name }

    /// `true` when the app is running on an iPhone or iPod touch.
    public static var isPhone: Bool { UIDevice.current.userInterfaceIdiom == .phone }

    /// `true` when the app is running on an iPad.
    public static var isPad: Bool { UIDevice.current.userInterfaceIdiom == .pad }

    /// `true` when the app is running inside the Xcode Simulator.
    public static var isSimulator: Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }

    /// The marketing version string from `Info.plist` (`CFBundleShortVersionString`), e.g. `"1.2.3"`.
    public static var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unknown"
    }

    /// The build number string from `Info.plist` (`CFBundleVersion`), e.g. `"42"`.
    public static var buildNumber: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "Unknown"
    }

    /// The app's bundle identifier from `Info.plist`, e.g. `"com.example.MyApp"`.
    public static var bundleIdentifier: String {
        Bundle.main.bundleIdentifier ?? "Unknown"
    }

    /// The logical size of the main screen in points.
    public static var screenSize: CGSize { UIScreen.main.bounds.size }

    /// The pixel density of the main screen (e.g. `2.0` for Retina, `3.0` for Super Retina).
    public static var screenScale: CGFloat { UIScreen.main.scale }

    /// `true` when the device is currently in landscape orientation.
    public static var isLandscape: Bool {
        UIDevice.current.orientation.isLandscape
    }

    /// `true` when the device has a sensor notch (safe-area top inset > 20 points).
    public static var hasNotch: Bool {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return false }
        return window.safeAreaInsets.top > 20
    }

    /// Total disk capacity of the device in bytes.
    public static var totalDiskSpace: Int64 {
        (try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory())[.systemSize] as? Int64) ?? 0
    }

    /// Available free disk space on the device in bytes.
    public static var freeDiskSpace: Int64 {
        (try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory())[.systemFreeSize] as? Int64) ?? 0
    }
}
#endif
