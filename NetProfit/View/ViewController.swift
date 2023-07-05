import UIKit
import RxSwift
import RxCocoa


final class CurrencyCell: UITableViewCell {
    
    @IBOutlet private weak var currencyTitleLabel: UILabel!
    @IBOutlet private weak var buyLabel: UILabel!
    @IBOutlet private weak var sellLabel: UILabel!
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.frame = self.contentView.frame.inset(by: UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0))
        self.contentView.layer.cornerRadius = 10
        self.contentView.layer.borderWidth = 0.5
        self.contentView.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    func setup(_ title: String, _ buy: String, _ sell: String) {
        self.currencyTitleLabel.text = title
        self.buyLabel.text = buy
        self.sellLabel.text = sell
    }
    
}


final class ViewController: UIViewController {
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var refreshButton: UIBarButtonItem!
    @IBOutlet private weak var errorLabel: UILabel!
    @IBOutlet private weak var expectedRateButton: UIButton!
    @IBOutlet private weak var customerRateButton: UIButton!
    @IBOutlet private weak var includeTaxSwitch: UISwitch!
    @IBOutlet private weak var calculationResult: UITextField!
    @IBOutlet private weak var calculationSum: UITextField!
    @IBOutlet private weak var copyButton: UIButton!
    @IBOutlet private weak var calculatorContentView: UIView!
    
    private let ratesViewModel: RatesViewModel = SolutionBankRatesViewModel()
    private let calculatorViewModel: CalculatorViewModel = SolutionBankCalculatorViewModel()
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupKeyboardLayout()
        self.setupView()
        self.errorLabel.isHidden = true
    }
    
    private func setupView() {
        self.bindRates()
        self.bindCalculator()
        self.ratesViewModel.fetch()
        self.calculatorViewModel.fetch()
    }
    
    private func bindRates() {
        self.ratesViewModel.loading.observe(on: MainScheduler.instance).bind { [weak self] isLoading in
            self?.loadingHandler(isLoading)
        }.disposed(by: self.disposeBag)
        self.ratesViewModel.currencies.observe(on: MainScheduler.instance).bind(to: self.tableView.rx.items(cellIdentifier: "CurrencyCell", cellType: CurrencyCell.self)) { row, item, cell in
            cell.setup(item.title, item.buy, item.sell)
        }.disposed(by: self.disposeBag)
        self.ratesViewModel.error.observe(on: MainScheduler.instance).bind { [weak self] errorMessage in
            self?.errorLabel.isHidden = errorMessage.isEmpty
            self?.errorLabel.text = errorMessage
        }.disposed(by: self.disposeBag)
        self.refreshButton.rx.tap.observe(on: MainScheduler.instance).bind { [weak self] _ in
            self?.ratesViewModel.fetch()
            self?.calculatorViewModel.fetch()
        }.disposed(by: self.disposeBag)
    }
    
    private func bindCalculator() {
        self.calculatorViewModel.calculationResult.bind(to: self.calculationResult.rx.text).disposed(by: self.disposeBag)
        self.calculatorViewModel.expectedCurrency.bind(to: self.expectedRateButton.rx.title(for: .normal)).disposed(by: self.disposeBag)
        self.calculatorViewModel.customerCurrency.bind(to: self.customerRateButton.rx.title(for: .normal)).disposed(by: self.disposeBag)
        self.expectedRateButton.rx.controlEvent(.touchUpInside).bind { [weak self] _ in
            self?.selectExpcetedCurrencies()
        }.disposed(by: self.disposeBag)
        self.customerRateButton.rx.controlEvent(.touchUpInside).bind { [weak self] _ in
            self?.selectCustomerCurrencies()
        }.disposed(by: self.disposeBag)
        self.includeTaxSwitch.rx.value.bind { [weak self] tax in
            self?.calculatorViewModel.didSetIncludeTax(tax)
        }.disposed(by: self.disposeBag)
        self.calculationSum.rx.text.bind { [weak self] text in
            guard let text = text else {
                self?.calculatorViewModel.didEneterSum(0)
                return
            }
            guard let doubleValue = Double(text) else {
                self?.calculatorViewModel.didEneterSum(0)
                return
            }
            self?.calculatorViewModel.didEneterSum(doubleValue)
        }.disposed(by: self.disposeBag)
        self.copyButton.rx.controlEvent(.touchUpInside).bind { [weak self] _ in
            UIPasteboard.general.string = self?.calculationResult.text ?? ""
            let ac = UIAlertController(title: "Copied to clipboard", message: nil, preferredStyle: .actionSheet)
            self?.present(ac, animated: true)
            ac.dismiss(animated: true)
        }.disposed(by: self.disposeBag)
    }

    private func loadingHandler(_ isLoading: Bool) {
        if isLoading {
            self.displayLoading()
        } else {
            self.displayEndLoading()
        }
    }
    
    private func selectExpcetedCurrencies() {
        let rates = self.calculatorViewModel.yourCurrencies
        let ac = UIAlertController(title: "Select currency:", message: nil, preferredStyle: .actionSheet)
        for rate in rates {
            ac.addAction(UIAlertAction(title: rate, style: .default, handler: { [weak self] _ in
                self?.calculatorViewModel.didSelectExpectedCurrency(rate)
            }))
        }
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.present(ac, animated: true)
    }
    
    private func selectCustomerCurrencies() {
        let rates = self.calculatorViewModel.customerCurrencies
        let ac = UIAlertController(title: "Select currency:", message: nil, preferredStyle: .actionSheet)
        for rate in rates {
            ac.addAction(UIAlertAction(title: rate, style: .default, handler: { [weak self] _ in
                self?.calculatorViewModel.didSelectCustomerCurrency(rate)
            }))
        }
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.present(ac, animated: true)
    }
    
}

