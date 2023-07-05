import Foundation
import SwiftSoup


protocol ExchangeRateParser {
    func parse() async throws -> [ExchangeRate]
}


struct SolutionBankParser: ExchangeRateParser {
    
    private let url = URL(string: "https://rbank.by/currency/")!
    
    func parse() async throws -> [ExchangeRate] {
        let (data, _) = try await URLSession.shared.data(for: URLRequest(url: self.url))
        guard let html = String(data: data, encoding: .utf8) else { return [] }
        return try self.handleHtml(html)
    }
    
    private func handleHtml(_ html: String) throws -> [ExchangeRate] {
        do {
            let doc = try SwiftSoup.parseBodyFragment(html)
            guard let currencies = try doc.select("div.currency-item__body")
                .first()?
                .select("div.currency-table__body-list")
                .select("div.currency-table__body-item")
                .select("span") else { return [] }
            let list = try currencies.html().split(separator: "\n").compactMap({ Double($0) })[0...5]
            return [
                ExchangeRate(currency: "USD", buy: list[0], sell: list[1]),
                ExchangeRate(currency: "EUR", buy: list[2], sell: list[3]),
                ExchangeRate(currency: "100 RUB", buy: list[4], sell: list[5])
            ]
        } catch {
            print(String(describing: error))
            throw error
        }
    }
    
}
