import Foundation


protocol RatesDataStore {
    func saveRates(_ rates: [ExchangeRate])
    func localRates() -> (rates: [ExchangeRate], date: Date)
}


struct UserDefaultsRatesDataStore: RatesDataStore {
    
    func saveRates(_ rates: [ExchangeRate]) {
        var dict = [String: [String: Double]]()
        for rate in rates {
            dict[rate.currency] = [
                "buy": rate.buy,
                "sell": rate.sell,
            ]
        }
        UserDefaults.standard.set(dict, forKey: "rates")
        UserDefaults.standard.set(Date.now, forKey: "ratesFetchDate")
    }
    
    func localRates() -> (rates: [ExchangeRate], date: Date){
        var rates = [ExchangeRate]()
        guard let ratesDict = UserDefaults.standard.dictionary(forKey: "rates") as? [String: [String: Double]] else { return ([], Date.now) }
        guard let date = UserDefaults.standard.object(forKey: "ratesFetchDate") as? Date else { return ([], Date.now) }
        for key in ratesDict.keys {
            guard let buy = ratesDict[key]?["buy"] else { continue }
            guard let sell = ratesDict[key]?["sell"] else { continue }
            rates.append(ExchangeRate(currency: key, buy: buy, sell: sell))
        }
        return (rates, date)
    }
    
}

