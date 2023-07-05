import Foundation


struct ExchangeRate {
    var currency: String
    var buy: Double
    var sell: Double
    
    func multiplyer() -> Double {
        let multiplyer = self.currency.contains("100") ? 100 : 1.0
        return multiplyer
    }
}
