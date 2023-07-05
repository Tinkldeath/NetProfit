import Foundation
import RxSwift


protocol RatesViewModel {
    var loading: BehaviorSubject<Bool> { get }
    var currencies: BehaviorSubject<[RateViewModel]> { get }
    var error: PublishSubject<String> { get }
    
    func fetch()
}


typealias RateViewModel = (title: String, buy: String, sell: String)


final class SolutionBankRatesViewModel: RatesViewModel {
    
    private(set) var currencies: BehaviorSubject<[RateViewModel]> = BehaviorSubject(value: [])
    private(set) var error: PublishSubject<String> = PublishSubject()
    private(set) var loading: BehaviorSubject<Bool> = BehaviorSubject(value: false)
    
    private var parser: ExchangeRateParser
    private var dataStore: RatesDataStore
    
    init() {
        self.parser = SolutionBankParser()
        self.dataStore = UserDefaultsRatesDataStore()
    }
    
    func fetch() {
        Task { [weak self] in
            do {
                self?.loading.onNext(true)
                guard let rates = try await self?.parser.parse() else { return }
                self?.dataStore.saveRates(rates)
                self?.currencies.onNext(rates.map({ RateViewModel($0.currency, String(floor($0.buy * 1000) / 1000) + " BYN", String(floor($0.sell * 1000) / 1000) + " BYN")  }))
                self?.loading.onNext(false)
                self?.error.onNext("")
            } catch {
                guard let results = self?.dataStore.localRates() else { return }
                self?.currencies.onNext(results.rates.map({ RateViewModel($0.currency, String(floor($0.buy * 1000) / 1000) + " BYN", String(floor($0.sell * 1000) / 1000) + " BYN")  }))
                self?.loading.onNext(false)
                self?.error.onNext("Displaying rates saved on \(results.date.formatted())")
            }
        }
    }
    
}
