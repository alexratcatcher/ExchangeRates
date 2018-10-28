//
//  CurrenciesListViewController.swift
//  ExchangeRatesMvvm
//
//  Created by Alexey Berkov on 24/10/2018.
//  Copyright © 2018 Alexey Berkov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources


class CurrenciesListViewController: UIViewController, StoryboardInstantiable, RefreshControlContainer {
    
    @IBOutlet private weak var tableView: UITableView!
    
    var viewModel: CurrenciesListViewModel!
    
    private let disposeBag = DisposeBag()
    
    lazy var refreshControl: UIRefreshControl = {
        let rc = UIRefreshControl()
        rc.attributedTitle = NSAttributedString(string: LS("PULL_TO_REFRESH"))
        rc.tintColor = UIColor.black
        return rc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(CurrencyTableViewCell.nib, forCellReuseIdentifier: CurrencyTableViewCell.cellIdentifier)
        tableView.register(NoCurrenciesTableViewCell.nib, forCellReuseIdentifier: NoCurrenciesTableViewCell.cellIdentifier)
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        self.bindTableViewDataSource()
        self.bindRefreshControl()
        self.bindItemSelection()
        self.bindErrorHandling()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.update.accept(())
    }
    
    private func bindTableViewDataSource() {
        let dataSource = RxTableViewSectionedAnimatedDataSource<CurrenciesSectionViewModel>(
            configureCell: { dataSource, tableView, indexPath, item in
                switch item {
                case CurrencyCellViewModel.noCurrenciesCell(message: let message):
                    let cell = tableView.dequeueReusableCell(withIdentifier: NoCurrenciesTableViewCell.cellIdentifier, for: indexPath) as! NoCurrenciesTableViewCell
                    cell.message = message
                    return cell
                case CurrencyCellViewModel.currencyCell(currency: let currency):
                    let cell = tableView.dequeueReusableCell(withIdentifier: CurrencyTableViewCell.cellIdentifier, for: indexPath) as! CurrencyTableViewCell
                    cell.currency = currency
                    return cell
                }
        })
        dataSource.titleForHeaderInSection = { dataSource, index in
            return dataSource.sectionModels[index].title
        }
        
        viewModel.sections
            .asDriver(onErrorJustReturn: [CurrenciesSectionViewModel]())
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    
    private func bindRefreshControl() {
        tableView.addSubview(refreshControl)
        refreshControl.rx.controlEvent(.valueChanged)
            .bind(to: viewModel.update)
            .disposed(by: disposeBag)
        
        viewModel.loading
            .observeOn(MainScheduler.instance)
            .bind(onNext: { [weak self] loading in
                if loading {
                    self?.showProgress()
                }
                else {
                    self?.hideProgress()
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func bindItemSelection() {
        tableView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                if let self = self, let tableView = self.tableView, let cell = tableView.cellForRow(at: indexPath) {
                    tableView.deselectRow(at: indexPath, animated: true)
                    
                    if let cell = cell as? CurrencyTableViewCell {
                        self.viewModel.selectItem.accept(cell.currency)
                    }
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func bindErrorHandling() {
        viewModel.error
            .observeOn(MainScheduler.instance)
            .bind(onNext: { [weak self] error in
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
                    self?.showErrorAlert(with: error.localizedDescription)
                }
            })
            .disposed(by: disposeBag)
    }
}
