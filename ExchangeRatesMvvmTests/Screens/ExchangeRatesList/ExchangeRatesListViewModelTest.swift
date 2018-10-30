//
//  ExchangeRatesListViewModelTest.swift
//  ExchangeRatesMvvmTests
//
//  Created by Alexey Berkov on 27/10/2018.
//  Copyright © 2018 Alexey Berkov. All rights reserved.
//

import XCTest
import RxSwift


@testable import ExchangeRatesMvvm


class ExchangeRatesListViewModelTest: XCTestCase {

    private var serviceMock: ExchangeRatesServiceMock!
    private var currenciesRepositoryMock: CurrenciesRepositoryMock!
    private var ratesRepositoryMock: ExchangeRatesRepositoryMock!
    private var disposeBag: DisposeBag!

    override func setUp() {
        serviceMock = ExchangeRatesServiceMock()
        currenciesRepositoryMock = CurrenciesRepositoryMock()
        ratesRepositoryMock = ExchangeRatesRepositoryMock()
        disposeBag = DisposeBag()
    }

    override func tearDown() {
        disposeBag = nil
        ratesRepositoryMock = nil
        currenciesRepositoryMock = nil
        serviceMock = nil
    }

    func testShouldRequestItemsFromRepositoryAndService() {
        let yesterday = Date().addingDays(-1)

        let usd = Currency(code: "USD", name: "Fake United States Dollar", selected: true)
        let euro = Currency(code: "EUR", name: "Fake Euro", selected: true)

        let existingRates = [ExchangeRate(currency: usd, date: yesterday, rate: 63.5),
                             ExchangeRate(currency: euro, date: yesterday, rate: 76.7)]

        let updatedRates = [ExchangeRate(currency: usd, date: yesterday, rate: 68.5),
                            ExchangeRate(currency: euro, date: yesterday, rate: 78.5)]

        ratesRepositoryMock.getRatesResultToReturn = existingRates
        currenciesRepositoryMock.getSelectedCurrenciesResultToReturn = [usd, euro]
        serviceMock.loadExchangeRatesResultToReturn = updatedRates

        let expectation = self.expectation(description: "Wait for loading completed")
        
        let viewModel = ExchangeRatesListViewModel(service: serviceMock,
                                                   currenciesRepository: RxCurrenciesRepository(repository: currenciesRepositoryMock),
                                                   ratesRepository: RxExchangeRatesRepository(repository: ratesRepositoryMock))

        var dataUpdates = [[ExchangeRatesSectionViewModel]]()
        viewModel.sections.bind(onNext: { data in
            dataUpdates.append(data)
            if dataUpdates.count > 2 {
                expectation.fulfill()
            }
        }).disposed(by: disposeBag)
        
        var loadingLog = [Bool]()
        viewModel.loading.bind(onNext: { loading in
            loadingLog.append(loading)
        }).disposed(by: disposeBag)
        
        var errorDidCalled = 0
        viewModel.error.bind(onNext: { error in
            errorDidCalled += 1
        }).disposed(by: disposeBag)
        
        viewModel.update.accept(())

        waitForExpectations(timeout: 1.0, handler: nil)
        
        XCTAssertEqual(dataUpdates.count, 3) //1 - empty on bind, 2 - existing, 3 - updated
        XCTAssertEqual(loadingLog, [true, false])
        XCTAssertEqual(errorDidCalled, 0)

        XCTAssertEqual(ratesRepositoryMock.deleteRatesForNotSelectedCurrenciesDidCalled, 1)
        XCTAssertEqual(ratesRepositoryMock.getRatesDidCalled, 2)
        XCTAssertEqual(currenciesRepositoryMock.getSelectedCurrenciesDidCalled, 1)
        XCTAssertEqual(serviceMock.loadExchangeRatesDidCalled, 5)
        XCTAssertEqual(ratesRepositoryMock.saveRatesDidCalled, 5)
        XCTAssertEqual(ratesRepositoryMock.saveRatesArgument, updatedRates)
        XCTAssertEqual(ratesRepositoryMock.deleteRatesForDatesBeforeDidCalled, 1)
    }

    func testShouldHandleErrorFromService() {
        let yesterday = Date().addingDays(-1)

        let usd = Currency(code: "USD", name: "Fake United States Dollar", selected: true)
        let euro = Currency(code: "EUR", name: "Fake Euro", selected: true)

        let existingRates = [ExchangeRate(currency: usd, date: yesterday, rate: 63.5),
                             ExchangeRate(currency: euro, date: yesterday, rate: 76.7)]

        let testError = NSError(domain: "Test", code: 42, userInfo: [NSLocalizedDescriptionKey : "TestError"])

        ratesRepositoryMock.getRatesResultToReturn = existingRates
        currenciesRepositoryMock.getSelectedCurrenciesResultToReturn = [usd, euro]
        serviceMock.loadExchangeRatesErrorToReturn = testError

        let expectation = self.expectation(description: "Wait for loading completed")
        
        let viewModel = ExchangeRatesListViewModel(service: serviceMock,
                                                   currenciesRepository: RxCurrenciesRepository(repository: currenciesRepositoryMock),
                                                   ratesRepository: RxExchangeRatesRepository(repository: ratesRepositoryMock))

        var dataUpdates = [[ExchangeRatesSectionViewModel]]()
        viewModel.sections.bind(onNext: { data in
            dataUpdates.append(data)
            if dataUpdates.count > 2 {
                expectation.fulfill()
            }
        }).disposed(by: disposeBag)
        
        var loadingLog = [Bool]()
        viewModel.loading.bind(onNext: { loading in
            loadingLog.append(loading)
        }).disposed(by: disposeBag)
        
        var errorDidCalled = 0
        viewModel.error.bind(onNext: { error in
            errorDidCalled += 1
        }).disposed(by: disposeBag)
        
        viewModel.update.accept(())

        waitForExpectations(timeout: 1.0, handler: nil)
        
        XCTAssertEqual(dataUpdates.count, 3) //1 - empty on bind, 2 - existing, 3 - updated
        XCTAssertEqual(loadingLog, [true, false])
        XCTAssertEqual(errorDidCalled, 1)

        XCTAssertEqual(ratesRepositoryMock.deleteRatesForNotSelectedCurrenciesDidCalled, 1)
        XCTAssertEqual(ratesRepositoryMock.getRatesDidCalled, 2)
        XCTAssertEqual(currenciesRepositoryMock.getSelectedCurrenciesDidCalled, 1)
        XCTAssertEqual(serviceMock.loadExchangeRatesDidCalled, 5)
        XCTAssertEqual(ratesRepositoryMock.saveRatesDidCalled, 0)
        XCTAssertEqual(ratesRepositoryMock.deleteRatesForDatesBeforeDidCalled, 0)
    }
}
