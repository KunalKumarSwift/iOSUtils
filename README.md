# iOSUtils

A Swift package of production-ready iOS utilities — storage, networking, validation, haptics, alerts, and a rich set of value-type extensions — built around a **Facade + Protocol Provider** pattern so every backend is swappable without touching call-site code.

## Requirements

| Platform | Minimum |
|----------|---------|
| iOS      | 15.0    |
| macOS    | 12.0    |

Swift 5.7+, Xcode 14+.

## Installation

### Swift Package Manager

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/KunalKumarSwift/iOSUtils", branch: "main")
],
targets: [
    .target(name: "YourTarget", dependencies: ["iOSUtils"])
]
```

Or add the package URL in Xcode via **File › Add Package Dependencies**.

---

## Architecture

```
iOSUtilsFacade.shared        ← single public entry point
       │
       ├── storage    → StorageProviding  (UserDefaults / Keychain / InMemory)
       ├── network    → NetworkMonitoring (NWPath / Mock)
       ├── validator  → ValidatorProviding (Standard)
       ├── haptics    → HapticsProviding  (UIKit / Mock)  [iOS only]
       └── alerts     → AlertPresenting   (UIKit)         [iOS only]
```

All provider backends are selected at **module load time** via environment variables — no code changes required to switch implementations. Protocols live in `providers/protocols/`, thin switch-only facades in `facades/`, and concrete implementations in `providers/`.

---

## Quick Start

```swift
import iOSUtils

let utils = iOSUtilsFacade.shared

// Storage
try utils.storage.set("auth-token-xyz", forKey: "token")
let token = try utils.storage.string(forKey: "token")

// Validation
let result = utils.validator.email("user@example.com")
if !result.isValid { print(result.errorMessage ?? "") }

// Network
utils.network.onStatusChange = { isConnected, type in
    print("Connected: \(isConnected), via: \(type)")
}
utils.network.startMonitoring()

// Haptics (iOS)
utils.haptics.notification(.success)

// Alerts (iOS)
utils.alerts.show(
    title: "Delete item?",
    message: nil,
    actions: [.destructive("Delete") { /* … */ }, .cancel()],
    on: self,
    style: .alert
)
```

---

## Subsystems

### Storage

**Protocol:** `StorageProviding`

| Method | Description |
|--------|-------------|
| `set(_ value: String, forKey:)` | Persist a UTF-8 string, overwriting any existing value. Throws `StorageError`. |
| `set(_ data: Data, forKey:)` | Persist raw bytes. Throws `StorageError`. |
| `string(forKey:)` | Retrieve a stored string. Throws `StorageError.notFound` or `.decodingFailed`. |
| `data(forKey:)` | Retrieve stored bytes. Throws `StorageError.notFound`. |
| `delete(forKey:) -> Bool` | Remove a key; returns `true` when the key existed. |
| `contains(key:) -> Bool` | Check whether a key has a stored value. |

**Implementations**

| Class | Env value | Notes |
|-------|-----------|-------|
| `UserDefaultsStorageProvider` | `userdefaults` *(default)* | Non-sensitive preferences. Suite name via `IOSUTILS_USERDEFAULTS_SUITE`. |
| `KeychainStorageProvider` | `keychain` | Sensitive data; iOS/macOS only. Service: `IOSUTILS_KEYCHAIN_SERVICE`, group: `IOSUTILS_KEYCHAIN_GROUP`. |
| `InMemoryStorageProvider` | `memory` | Thread-safe, non-persistent; ideal for tests. |

**Error type:** `StorageError` (`.notFound`, `.decodingFailed`, `.encodingFailed`, `.systemError(Int32)`)

```swift
// Select backend via environment variable (before module load)
setenv("IOSUTILS_STORAGE_PROVIDER", "keychain", 1)
```

---

### Network Monitoring

**Protocol:** `NetworkMonitoring`

| Member | Description |
|--------|-------------|
| `isConnected: Bool` | Current connectivity state. |
| `connectionType: ConnectionType` | Active interface: `.wifi`, `.cellular`, `.ethernet`, `.unknown`. |
| `onStatusChange: NetworkStatusHandler?` | Callback delivered on the **main thread** when state changes. Set before calling `startMonitoring()`. |
| `startMonitoring()` | Begin observing. |
| `stopMonitoring()` | Stop observing and release system resources. |

**Implementations**

| Class | Env value | Notes |
|-------|-----------|-------|
| `NWPathNetworkProvider` | `nwpath` *(default)* | Backed by `Network.framework`; Apple platforms only. |
| `MockNetworkProvider` | `mock` | Synchronous; use `simulateChange(isConnected:type:)` in tests. |

```swift
let monitor = iOSUtilsFacade.shared.network
monitor.onStatusChange = { connected, type in … }
monitor.startMonitoring()
```

---

### Validation

**Protocol:** `ValidatorProviding`

| Method | Description |
|--------|-------------|
| `email(_:) -> ValidationResult` | RFC-style email pattern check. |
| `phone(_:) -> ValidationResult` | E.164-compatible digit count check. |
| `password(_:minLength:requireUppercase:requireDigit:requireSpecial:)` | Configurable complexity rules. |
| `notEmpty(_:fieldName:) -> ValidationResult` | Non-blank field check with a custom field name in the error message. |
| `url(_:) -> ValidationResult` | `URL`-parseable string check. |
| `creditCard(_:) -> ValidationResult` | Luhn algorithm; strips spaces and dashes before checking. |

**Result type:** `ValidationResult` — `.valid` or `.invalid(String)` with helpers `isValid: Bool` and `errorMessage: String?`.

```swift
let result = iOSUtilsFacade.shared.validator.password(
    password,
    minLength: 8,
    requireUppercase: true,
    requireDigit: true,
    requireSpecial: false
)
guard result.isValid else {
    showError(result.errorMessage)
    return
}
```

---

### Haptics *(iOS only)*

**Protocol:** `HapticsProviding`

| Method | Description |
|--------|-------------|
| `impact(_ style:)` | Impact feedback at the given `UIImpactFeedbackGenerator.FeedbackStyle`. |
| `notification(_ type:)` | Semantic feedback at the given `UINotificationFeedbackGenerator.FeedbackType`. |
| `selection()` | Selection-changed feedback. |

**Implementations:** `UIKitHapticsProvider` (default) · `MockHapticsProvider` (records calls for tests).

```swift
iOSUtilsFacade.shared.haptics.notification(.success)
iOSUtilsFacade.shared.haptics.impact(.medium)
```

---

### Alerts *(iOS only)*

**Protocol:** `AlertPresenting`

```swift
func show(
    title: String?,
    message: String?,
    actions: [AlertAction],
    on viewController: UIViewController,
    style: UIAlertController.Style
)
```

**`AlertAction` factories**

```swift
AlertAction(title: "OK")                          // default style
AlertAction.cancel()                               // cancel style, title "Cancel"
AlertAction.cancel("No thanks") { doSomething() } // custom cancel title
AlertAction.destructive("Delete") { delete() }    // destructive style
```

---

## Extensions

### `String`

| Member | Description |
|--------|-------------|
| `isBlank` | `true` when empty or whitespace-only. |
| `trimmed` | Leading/trailing whitespace removed. |
| `isValidEmail` | Regex-based email pattern check. |
| `isValidURL` | Parseable as a `URL`. |
| `isNumeric` | All characters are decimal digits. |
| `toInt` / `toDouble` / `toBool` | Type-safe conversions; return `nil` on failure. |
| `base64Encoded` / `base64Decoded` | Round-trip Base64 helpers. |
| `truncated(to:trailing:)` | Trim to a max length and append a trailing token. |
| `words()` | Split on whitespace into non-empty components. |
| `camelCased()` | `"hello-world"` → `"helloWorld"` |
| `snakeCased()` | `"myVar"` → `"my_var"` |
| `contains(_:caseInsensitive:)` | Optional case-insensitive substring search. |
| `[safe: index]` | `Character?` — nil instead of a crash when out of range. |
| `[range: Range<Int>]` | Integer-indexed substring, clamped to valid range. |

### `Array` / `Collection`

| Member | Description |
|--------|-------------|
| `[safe: index]` | `Element?` — nil instead of a crash. |
| `chunked(into:)` | Split into sub-arrays of at most *n* elements. |
| `unique(by:)` | De-duplicate by key path, preserving order. |
| `unique()` | De-duplicate `Hashable` elements, preserving order. |
| `frequency()` | Count occurrences of each `Hashable` element. |
| `removing(_:)` | Return a copy without the given `Equatable` element. |
| `remove(_:)` | Mutating removal of all equal elements. |
| `isNotEmpty` | Convenience inverse of `isEmpty` on any `Collection`. |

### `Date`

| Member | Description |
|--------|-------------|
| `isToday` / `isYesterday` / `isTomorrow` | Calendar-day checks. |
| `isInFuture` / `isInPast` | Comparison against `Date()`. |
| `startOfDay` / `endOfDay` | Midnight and 23:59:59 of the same day. |
| `startOfMonth` / `endOfMonth` | First and last second of the calendar month. |
| `age` | Whole years between the date and today. |
| `adding(_:value:)` | Add any `Calendar.Component`. |
| `formatted(_:locale:)` | Custom `DateFormatter` string. |
| `relativeFormatted()` | "2 hours ago" style (Apple) or absolute fallback (Linux). |
| `daysBetween(_:)` | Absolute calendar-day count between two dates. |
| `Date.from(string:format:)` | Parse a `Date` from a formatted string. |

### `UIColor` *(iOS only)*

| Member | Description |
|--------|-------------|
| `init(hex:alpha:)` | Create from a 6- or 8-digit hex string with optional alpha. |
| `hexString` | `"#RRGGBB"` representation. |
| `lighter(by:)` / `darker(by:)` | Brightness-adjusted copies. |
| `complementary` | Hue-shifted 180° colour. |
| `UIColor.random(alpha:)` | Random RGB colour. |

### `UIView` *(iOS only)*

| Member | Description |
|--------|-------------|
| `addSubviews(_:)` | Add multiple subviews in one call. |
| `pinToEdges(of:insets:)` | Auto Layout pin to all four edges with optional insets. |
| `center(in:)` | Auto Layout centre in a view. |
| `roundCorners(_:)` | Corner radius + `masksToBounds`. |
| `addShadow(color:opacity:offset:radius:)` | Layer shadow in one call. |
| `addBorder(color:width:)` | Layer border in one call. |
| `shake(duration:intensity:)` | Horizontal shake animation (error indicator). |
| `fadeIn(duration:completion:)` | Animate alpha from 0 → 1, unhides view first. |
| `fadeOut(duration:completion:)` | Animate alpha to 0, then hides view. |
| `snapshot()` | Render to `UIImage`. |
| `parentViewController` | Walk responder chain to find enclosing `UIViewController`. |

---

## DeviceInfo *(iOS only)*

`DeviceInfo` provides static read-only properties for hardware and app metadata.

```swift
print(DeviceInfo.modelName)        // "iPhone15,2"
print(DeviceInfo.systemVersion)    // "17.0"
print(DeviceInfo.appVersion)       // "1.0.0"
print(DeviceInfo.freeDiskSpace)    // bytes available
print(DeviceInfo.isSimulator)      // true/false
```

| Property | Description |
|----------|-------------|
| `modelName` | Raw hardware identifier from `uname`. |
| `systemVersion` / `systemName` | OS version and name. |
| `deviceName` | User-assigned device name. |
| `isPhone` / `isPad` | Idiom checks. |
| `isSimulator` | Compile-time simulator detection. |
| `appVersion` / `buildNumber` / `bundleIdentifier` | `Info.plist` values. |
| `screenSize` / `screenScale` | Main screen geometry. |
| `isLandscape` | Current orientation. |
| `hasNotch` | Safe-area top inset > 20 pt. |
| `totalDiskSpace` / `freeDiskSpace` | Disk capacity in bytes. |

---

## Environment Variables

| Variable | Values | Default | Subsystem |
|----------|--------|---------|-----------|
| `IOSUTILS_STORAGE_PROVIDER` | `userdefaults` · `keychain` · `memory` | `userdefaults` | Storage |
| `IOSUTILS_USERDEFAULTS_SUITE` | Suite name string | `.standard` | Storage |
| `IOSUTILS_KEYCHAIN_SERVICE` | Service identifier | Bundle ID | Storage |
| `IOSUTILS_KEYCHAIN_GROUP` | Access group string | *(none)* | Storage |
| `IOSUTILS_NETWORK_PROVIDER` | `nwpath` · `mock` | `nwpath` | Network |
| `IOSUTILS_VALIDATOR_PROVIDER` | `standard` | `standard` | Validation |
| `IOSUTILS_HAPTICS_PROVIDER` | `uikit` · `mock` | `uikit` | Haptics |
| `IOSUTILS_ALERT_PROVIDER` | `uikit` | `uikit` | Alerts |

Variables must be set **before the module is first imported** (i.e. before the process reads them at module load time).

---

## Testing

```bash
swift test --parallel
```

The test suite runs on both **macOS** and **Linux**. Apple-only subsystems (Keychain, NWPath, UIKit) are compile-guarded and fall back to cross-platform alternatives so all tests pass on Linux.

For unit tests, inject mock providers directly:

```swift
let mockStorage = InMemoryStorageProvider()
let mockNetwork = MockNetworkProvider()

// Simulate a network change in a test
mockNetwork.simulateChange(isConnected: false, type: .unknown)
```

---

## CI

GitHub Actions runs the full test suite on every push and pull request:

- **macOS 14** — `swift test --parallel`
- **Ubuntu Latest** — `swift test --parallel`

See [`.github/workflows/tests.yml`](.github/workflows/tests.yml).

---

## License

MIT. See [LICENSE](LICENSE) for details.
