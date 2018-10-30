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
    
    private var viewModel: ExchangeRatesListViewModel!
    
    private var serviceMock: ExchangeRatesServiceMock!
    private var currenciesRepositoryMock: CurrenciesRepositoryMock!
    private var ratesRepositoryMock: ExchangeRatesRepositoryMock!
    private var dateProvider: DateProviderProtocol!
    
    private var disposeBag: DisposeBag!
    
    override func setUp() {
        serviceMock = ExchangeRatesServiceMock()
        currenciesRepositoryMock = CurrenciesRepositoryMock()
        ratesRepositoryMock = ExchangeRatesRepositoryMock()
        dateProvider = DateProvider()
        
        viewModel = ExchangeRatesListViewModel(service: serviceMock,
                                               currenciesRepository: currenciesRepositoryMock,
                                               ratesRepository: ratesRepositoryMock,
                                               dateProvider: dateProvider)
        
        disposeBag = DisposeBag()
    }
    
    override func tearDown() {
        disposeBag = nil
        
        viewModel = nil
        
        dateProvider = nil
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
        
        var log = [[ExchangeRatesSectionViewModel]]()
        viewModel.sections.bind(onNext: { data in
            log.append(data)
            if log.count > 2 {
                expectation.fulfill()
            }
        }).disposed(by: disposeBag)
        
        viewModel.update.accept(())
        
        waitForExpectations(timeout: 1.0, handler: nil)
        
//        XCTAssertTrue(states[0] == ExchangeRatesListViewState.rates) //1 - on bind
//        XCTAssertTrue(states[1] == ExchangeRatesListViewState.rates) //2 - on cached items shown
//        XCTAssertTrue(states[2] == ExchangeRatesListViewState.loading)
//        XCTAssertTrue(states[3] == ExchangeRatesListViewState.rates) //3 - on updated items shown
        
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
        
        var log = [[ExchangeRatesSectionViewModel]]()
        viewModel.sections.bind(onNext: { data in
            log.append(data)
            if log.count > 2 {
                expectation.fulfill()
            }
        }).disposed(by: disposeBag)
        
        viewModel.update.accept(())
        
        waitForExpectations(timeout: 1.0, handler: nil)
        
//        XCTAssertTrue(states[0] == ExchangeRatesListViewState.rates) //1 - on bind
//        XCTAssertTrue(states[1] == ExchangeRatesListViewState.rates) //2 - on cached items shown
//        XCTAssertTrue(states[2] == ExchangeRatesListViewState.loading)
//        XCTAssertTrue(states[3] == ExchangeRatesListViewState.error(testError)) //3 - on updated items shown
        
        XCTAssertEqual(ratesRepositoryMock.deleteRatesForNotSelectedCurrenciesDidCalled, 1)
        XCTAssertEqual(ratesRepositoryMock.getRatesDidCalled, 1)
        XCTAssertEqual(currenciesRepositoryMock.getSelectedCurrenciesDidCalled, 1)
        XCTAssertEqual(serviceMock.loadExchangeRatesDidCalled, 5)
        XCTAssertEqual(ratesRepositoryMock.saveRatesDidCalled, 0)
        XCTAssertEqual(ratesRepositoryMock.deleteRatesForDatesBeforeDidCalled, 0)
    }
}
