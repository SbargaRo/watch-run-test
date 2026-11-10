import Foundation
import HealthKit

final class HealthManager: ObservableObject {
    private let store = HKHealthStore()

    @Published var status: String = "Premi il pulsante"
    @Published var heartRate: Double? = nil

    func requestAndRead() {
        guard HKHealthStore.isHealthDataAvailable() else {
            status = "HealthKit non disponibile"
            return
        }
        guard let type = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            status = "Tipo dato non valido"
            return
        }
        store.requestAuthorization(toShare: [], read: [type]) { success, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.status = "Errore: \(error.localizedDescription)"
                } else if success {
                    self.readLatest(type)
                } else {
                    self.status = "Permesso negato"
                }
            }
        }
    }

    private func readLatest(_ type: HKQuantityType) {
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let query = HKSampleQuery(sampleType: type, predicate: nil, limit: 1, sortDescriptors: [sort]) { _, samples, error in
            DispatchQueue.main.async {
                if let sample = samples?.first as? HKQuantitySample {
                    let unit = HKUnit.count().unitDivided(by: HKUnit.minute())
                    self.heartRate = sample.quantity.doubleValue(for: unit)
                    self.status = "Ultimo battito registrato"
                } else {
                    self.status = error?.localizedDescription ?? "Nessun dato trovato"
                }
            }
        }
        store.execute(query)
    }
}
