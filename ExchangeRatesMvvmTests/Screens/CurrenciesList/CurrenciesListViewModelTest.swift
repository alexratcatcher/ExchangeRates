//
//  CurrenciesListViewModelTest.swift
//  ExchangeRatesMvvmTests
//
//  Created by Alexey Berkov on 27/10/2018.
//  Copyright © 2018 Alexey Berkov. All rights reserved.
//

import XCTest
import RxSwift
import RxTest


@testable import ExchangeRatesMvvm


class CurrenciesListViewModelTest: XCTestCase {
    
    private var serviceMock: CurrenciesServiceMock!
    private var currenciesRepositoryMock: CurrenciesRepositoryMock!
    
    private var disposeBag: DisposeBag!

    override func setUp() {
        serviceMock = CurrenciesServiceMock()
        currenciesRepositoryMock = CurrenciesRepositoryMock()

        disposeBag = DisposeBag()
    }

    override func tearDown() {
        disposeBag = nil
        
        currenciesRepositoryMock = nil
        serviceMock = nil
    }

    // Show currencies
    
    func testShouldRequestItemsFromRepositoryAndService() {
        let existingCurrencies = [Currency(code: "USD", name: "Fake United States Dollar", selected: true),
                                  Currency(code: "RUB", name: "Fake Russian Ruble", selected: false),
                                  Currency(code: "EUR", name: "Fake Euro", selected: false),
                                  Currency(code: "YEN", name: "Fake Japan Yen", selected: false)]
        
        let updatedCurrencies = [Currency(code: "USD", name: "Fake United States Dollar", selected: true),
                                 Currency(code: "RUB", name: "True Russian Ruble", selected: true),
                                 Currency(code: "ARS", name: "Fake Argentina Peso", selected: false)]
        
        currenciesRepositoryMock.getSelectedCurrenciesResultToReturn = existingCurrencies.filter({ $0.selected })
        currenciesRepositoryMock.getOtherCurrenciesResultToReturn = existingCurrencies.filter({ !$0.selected })
        serviceMock.loadCurrenciesResultToReturn = updatedCurrencies
        
        let expectation = self.expectation(description: "Wait for completion")
        
        let viewModel = CurrenciesListViewModel(service: serviceMock,
                                                currenciesRepository: currenciesRepositoryMock)
        
        var dataUpdates = [[CurrenciesSectionViewModel]]()
        viewModel.sections.bind(onNext: { data in
            dataUpdates.append(data)
            if dataUpdates.count > 2 {
                expectation.fulfill()
            }
        }).disposed(by: disposeBag)
        
        viewModel.update.accept(())
        
        /*
        var loadingLog = [Bool]()
        viewModel.loading.bind(onNext: { loading in
            loadingLog.append(loading)
        }).disposed(by: disposeBag)
        
        var errorDidCalled = 0
        viewModel.error.bind(onNext: { error in
            errorDidCalled += 1
        }).disposed(by: disposeBag)
        */
        
        waitForExpectations(timeout: 5.0, handler: { error in
            print("expectation completed")
            XCTAssertNil(error)
            XCTAssertEqual(self.currenciesRepositoryMock.getSelectedCurrenciesDidCalled, 2)
            XCTAssertEqual(self.currenciesRepositoryMock.getOtherCurrenciesDidCalled, 2)
            XCTAssertEqual(self.serviceMock.loadCurrenciesDidCalled, 1)
            XCTAssertEqual(self.currenciesRepositoryMock.saveCurrenciesDidCalled, 1)
            XCTAssertEqual(self.currenciesRepositoryMock.saveCurrenciesArgument, updatedCurrencies)
        })
    }
    
//    func testShouldHandleErrorFromService() {
//        let existingCurrencies = [Currency(code: "USD", name: "Fake United States Dollar", selected: true),
//                                  Currency(code: "RUB", name: "Fake Russian Ruble", selected: false),
//                                  Currency(code: "EUR", name: "Fake Euro", selected: false),
//                                  Currency(code: "YEN", name: "Fake Japan Yen", selected: false)]
//        let testError = NSError(domain: "Test", code: 42, userInfo: [NSLocalizedDescriptionKey : "TestError"])
//
//        currenciesRepositoryMock.getSelectedCurrenciesResultToReturn = existingCurrencies.filter({ $0.selected })
//        currenciesRepositoryMock.getOtherCurrenciesResultToReturn = existingCurrencies.filter({ !$0.selected })
//        serviceMock.loadCurrenciesResultToReturn = [Currency]()
//
//        let expectation = self.expectation(description: "Wait for loading completed")
//
//        var log = [[CurrenciesSectionViewModel]]()
//        viewModel.sections.bind(onNext: { data in
//            log.append(data)
//            if log.count > 2 {
//                expectation.fulfill()
//            }
//        }).disposed(by: disposeBag)
//
//        viewModel.update.accept(())
//
//        waitForExpectations(timeout: 1.0, handler: nil)
//
//        XCTAssertEqual(currenciesRepositoryMock.getSelectedCurrenciesDidCalled, 1)
//        XCTAssertEqual(currenciesRepositoryMock.getOtherCurrenciesDidCalled, 1)
//        XCTAssertEqual(serviceMock.loadCurrenciesDidCalled, 1)
//        XCTAssertEqual(currenciesRepositoryMock.saveCurrenciesDidCalled, 0)
//    }
    
    // Change currency selection
    
//    func testShouldHandleSuccessfulCurrencySelection() {
//        testShouldRequestItemsFromRepositoryAndService()
//
//        let currency = CurrencyViewModel(code: "USD", name: "United States Dollar", selected: false)
//        currenciesRepositoryMock.markCurrencySelectedResultToReturn = Currency(code: "USD", name: "United States Dollar", selected: true)
//
//        let expectation = self.expectation(description: "Wait for update completed")
//
//        var log = [[CurrenciesSectionViewModel]]()
//        viewModel.sections.bind(onNext: { data in
//            log.append(data)
//            if log.count > 2 {
//                expectation.fulfill()
//            }
//        }).disposed(by: disposeBag)
//
//        viewModel.selectItem.accept(currency)
//
//        waitForExpectations(timeout: 1.0, handler: nil)
//
//        XCTAssertEqual(currenciesRepositoryMock.markCurrencySelectedDidCalled, 1)
//        XCTAssertEqual(currenciesRepositoryMock.markCurrencySelectedCodeArgument, "USD")
//        XCTAssertEqual(currenciesRepositoryMock.markCurrencySelectedSelectedArgument, !currency.selected)
//    }
}
