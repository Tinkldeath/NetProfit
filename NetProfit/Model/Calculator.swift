import Foundation


struct Calculator {
    
    func calculate(_ expectedRate: ExchangeRate, _ customerRate: ExchangeRate, _ sum: Double, _ includeTax: Bool) -> Double? {
        guard sum > 0 else { return nil }
        if includeTax {
            if expectedRate.currency.contains("100") {
                let expectedBynSum = (expectedRate.sell / expectedRate.multiplyer() * sum + 5) / 0.9
                return expectedBynSum * customerRate.multiplyer() / customerRate.sell
            } else {
                let expectedBynSum = (expectedRate.sell * expectedRate.multiplyer() * sum + 5) / 0.9
                return expectedBynSum * customerRate.multiplyer() / customerRate.sell
            }
        } else {
            if expectedRate.currency.contains("100") {
                let expectedBynSum = (expectedRate.sell / expectedRate.multiplyer() * sum + 5)
                return expectedBynSum * customerRate.multiplyer() / customerRate.sell
            } else {
                let expectedBynSum = (expectedRate.sell * expectedRate.multiplyer() * sum + 5)
                return expectedBynSum * customerRate.multiplyer() / customerRate.sell
            }
        }
    }
    
}
