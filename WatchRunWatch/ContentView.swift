import SwiftUI

struct ContentView: View {
    @StateObject private var health = HealthManager()

    var body: some View {
        VStack(spacing: 8) {
            if let hr = health.heartRate {
                Text("\(Int(hr.rounded()))")
                    .font(.system(size: 48, weight: .bold))
                Text("bpm")
                    .foregroundStyle(.secondary)
            }
            Text(health.status)
                .font(.footnote)
                .multilineTextAlignment(.center)
            Button("Leggi battito") {
                health.requestAndRead()
            }
        }
        .padding()
    }
}
