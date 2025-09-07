import SwiftUI

/// Simple settings for target distance and time window.
struct SettingsView: View {
    @AppStorage("targetWindowSec") private var targetWindowSec: Int = 1800
    @AppStorage("targetDistance") private var targetDistance: Double = 5000

    var body: some View {
        Form {
            Stepper(value: $targetDistance, in: 1000...42195, step: 1000) {
                Text("Distance: \(Int(targetDistance/1000)) km")
            }
            Stepper(value: $targetWindowSec, in: 300...7200, step: 60) {
                Text("Window: \(targetWindowSec/60) min")
            }
        }
    }
}
