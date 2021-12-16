//
//  GoogleDataSource.swift
//  GoogleSearch
//
//  Created by Александр Басов on 12/16/21.
//

import UIKit

class GoogleDataSource: NSObject {
    
    // - TableView
    private var tableView: UITableView
    
    // - ViewModel
    private var viewModel: GoogleViewModel
    
    // - Delegate
    weak var delegate: GoogleDelegate?
    
    init(tableView: UITableView, viewModel: GoogleViewModel) {
        self.tableView = tableView
        self.viewModel = viewModel
        super.init()
        configure()
    }
}

//MARK: - UITableView Data Source
extension GoogleDataSource: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return googleCell(cellForRowAt: indexPath)
    }

}

//MARK: - Cell
private extension GoogleDataSource {
    
    func googleCell(cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: GoogleCell.reuseID, for: indexPath) as! GoogleCell
        cell.set(item: viewModel.items[indexPath.row])
        return cell
    }
    
}

//MARK: - UITableView Delegate
extension GoogleDataSource: UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.scrollViewDidScroll(y: scrollView.contentOffset.y)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = viewModel.items[indexPath.row]
        guard let url = URL(string: item.link ?? "") else { return }
        delegate?.didTapOnItem(url: url)
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        UIView.animate(withDuration: 0.2) {
            if let cell = tableView.cellForRow(at: indexPath) {
                cell.transform = .init(scaleX: 0.92, y: 0.92)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        UIView.animate(withDuration: 0.3, animations: {
            if let cell = tableView.cellForRow(at: indexPath) {
                cell.transform = .identity
            }
        })
    }
    
}

//MARK: - Configure
private extension GoogleDataSource {
    
    func configure() {
        registerCells()
        setupDataSource()
    }
    
    func setupDataSource() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInset = .init(top: 0, left: 0, bottom: 60, right: 0)
    }
    
    func registerCells() {
        tableView.register(GoogleCell.nib(), forCellReuseIdentifier: GoogleCell.reuseID)
    }
    
}
