//
//  ExchangeRatesListViewController.swift
//  ExchangeRatesMvvm
//
//  Created by Alexey Berkov on 25/10/2018.
//  Copyright © 2018 Alexey Berkov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources


class ExchangeRatesListViewController: UIViewController, StoryboardInstantiable, RefreshControlContainer {
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var noResultsLabel: UILabel!

    var viewModel: ExchangeRatesListViewModel!
    var onSettingsPressedBlock: (()->Void)!
    
    private let disposeBag = DisposeBag()
    
    lazy var refreshControl: UIRefreshControl = {
        let rc = UIRefreshControl()
        rc.attributedTitle = NSAttributedString(string: LS("PULL_TO_REFRESH"))
        rc.tintColor = UIColor.black
        return rc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(ExchangeRateTableViewCell.nib, forCellReuseIdentifier: ExchangeRateTableViewCell.cellIdentifier)
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        noResultsLabel.isHidden = true
        
        self.bindTableViewDataSource()
        self.bindRefreshControl()
        self.bindErrorHandling()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.update.accept(())
    }
    
    @IBAction func onSettingsButtonPressed(_ sender: Any) {
        self.onSettingsPressedBlock()
    }
    
    private func bindTableViewDataSource() {
        let dataSource = RxTableViewSectionedAnimatedDataSource<ExchangeRatesSectionViewModel>(
            configureCell: { dataSource, tableView, indexPath, item in
                let cell = tableView.dequeueReusableCell(withIdentifier: ExchangeRateTableViewCell.cellIdentifier, for: indexPath) as! ExchangeRateTableViewCell
                cell.show(rate: item)
                return cell
        })
        dataSource.titleForHeaderInSection = { dataSource, index in
            return dataSource.sectionModels[index].title
        }
        
        viewModel.sections
            .asDriver(onErrorJustReturn: [ExchangeRatesSectionViewModel]())
            .do(onNext: { [weak self] sections in
                if sections.isEmpty {
                    self?.showNoResults()
                }
                else {
                    self?.hideNoResults()
                }
            })
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
            .bind(onNext: { loading in
                if loading {
                    self.showProgress()
                }
                else {
                    self.hideProgress()
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
    
    private func showNoResults() {
        self.noResultsLabel.text = LS("RATES_SCREEN_NO_RATES")
        self.noResultsLabel.isHidden = false
    }
    
    private func hideNoResults() {
        self.noResultsLabel.isHidden = true
    }
}
