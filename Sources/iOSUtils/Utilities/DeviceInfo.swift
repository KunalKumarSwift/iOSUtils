/// Read-only device and app metadata helpers.
///
/// All properties are static and read from system APIs at call time.
/// Does not use the Facade pattern because there is no swappable backend.
/// No environment variables are consumed here.
#if canImport(UIKit)
import UIKit

public struct DeviceInfo {

    public static var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        return machineMirror.children.compactMap { $0.value as? Int8 }.filter { $0 != 0 }.map { String(UnicodeScalar(UInt8($0))) }.joined()
    }

    public static var systemVersion: String { UIDevice.current.systemVersion }
    public static var systemName: String { UIDevice.current.systemName }
    public static var deviceName: String { UIDevice.current.name }

    public static var isPhone: Bool { UIDevice.current.userInterfaceIdiom == .phone }
    public static var isPad: Bool { UIDevice.current.userInterfaceIdiom == .pad }

    public static var isSimulator: Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }

    public static var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unknown"
    }

    public static var buildNumber: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "Unknown"
    }

    public static var bundleIdentifier: String {
        Bundle.main.bundleIdentifier ?? "Unknown"
    }

    public static var screenSize: CGSize { UIScreen.main.bounds.size }
    public static var screenScale: CGFloat { UIScreen.main.scale }

    public static var isLandscape: Bool {
        UIDevice.current.orientation.isLandscape
    }

    public static var hasNotch: Bool {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return false }
        return window.safeAreaInsets.top > 20
    }

    public static var totalDiskSpace: Int64 {
        (try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory())[.systemSize] as? Int64) ?? 0
    }

    public static var freeDiskSpace: Int64 {
        (try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory())[.systemFreeSize] as? Int64) ?? 0
    }
}
#endif
