import Foundation
import Shared

// Test KMP integration
let calculator = PurdyPointsCalculator()
let ppi = calculator.calculatePPI(distance: 1000.0, time: 300) // 1km in 5 minutes
print("PPI Score: \(ppi)")

// Test other shared functionality
let service = MeBeatMeService()
print("Service initialized: \(service)")
