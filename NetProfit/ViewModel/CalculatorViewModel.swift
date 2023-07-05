import Foundation
import RxSwift


protocol CalculatorViewModel {
    var yourCurrencies: [String] { get }
    var customerCurrencies: [String] { get }
    var expectedCurrency: BehaviorSubject<String> { get }
    var customerCurrency: BehaviorSubject<String> { get }
    var calculationResult: PublishSubject<String> { get }
    
    func fetch()
    func didSelectExpectedCurrency(_ currency: String)
    func didSelectCustomerCurrency(_ currency: String)
    func didSetIncludeTax(_ tax: Bool)
    func didEneterSum(_ sum: Double)
}


final class SolutionBankCalculatorViewModel: CalculatorViewModel {

    private(set) var expectedCurrency: BehaviorSubject<String> = BehaviorSubject(value: "USD")
    private(set) var customerCurrency: BehaviorSubject<String> = BehaviorSubject(value: "RUB")
    private(set) var calculationResult: PublishSubject<String> = PublishSubject()
    private(set) var customerCurrencies: [String] = []
    private(set) var yourCurrencies: [String] = []
    
    private var dataStore: RatesDataStore
    private var rates: [ExchangeRate] = []
    private var calculator = Calculator()
    private var expectedRate: ExchangeRate?
    private var customerRate: ExchangeRate?
    private var includeTax: Bool = true
    private var sum = 0.0
    
    init() {
        self.dataStore = UserDefaultsRatesDataStore()
        self.rates = self.dataStore.localRates().rates
        self.didSelectExpectedCurrency("USD")
        self.didSelectCustomerCurrency("100 RUB")
    }
    
    func fetch() {
        let rates = self.dataStore.localRates().rates
        self.rates = rates
    }
    
    func didSelectExpectedCurrency(_ currency: String) {
        guard let selection = self.rates.first(where: { $0.currency == currency }) else { return }
        self.expectedRate = selection
        self.customerCurrencies = self.rates.map({ $0.currency }).filter({ $0 != currency })
        self.expectedCurrency.onNext(currency)
        self.calculate()
    }
    
    func didSelectCustomerCurrency(_ currency: String) {
        guard let selection = self.rates.first(where: { $0.currency == currency }) else { return }
        self.customerRate = selection
        self.yourCurrencies = self.rates.map({ $0.currency }).filter({ $0 != currency })
        self.customerCurrency.onNext(currency)
        self.calculate()
    }
    
    func didSetIncludeTax(_ tax: Bool) {
        self.includeTax = tax
        self.calculate()
    }
    
    func didEneterSum(_ sum: Double) {
        self.sum = sum
        self.calculate()
    }
    
    private func calculate() {
        guard let expectedRate = self.expectedRate else {
            self.calculationResult.onNext("")
            return
        }
        guard let customerRate = self.customerRate else {
            self.calculationResult.onNext("")
            return
        }
        guard let sum = self.calculator.calculate(expectedRate, customerRate, self.sum, self.includeTax) else {
            self.calculationResult.onNext("")
            return
        }
        self.calculationResult.onNext(String(Int(sum)))
    }
    
}
