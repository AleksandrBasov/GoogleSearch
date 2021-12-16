//
//  GoogleViewModel.swift
//  GoogleSearch
//
//  Created by Александр Басов on 12/16/21.
//

import Foundation

class GoogleViewModel {
    
    // - Data
    var items: [Item] = []
    var isSearchActive: Bool = false
    
    // - Managers
    private let network = NetworkManager.shared
    
    // - Delegate
    weak var delegate: GoogleDelegate?
    
    func getItems(text: String?) {
        delegate?.showProgress()
        network.getGoogleSearch(text: text) { items in
            self.items = items
            self.delegate?.hideProgress()
            self.delegate?.fetchFinished()
            print(self.items.count)
        } onError: { error in
            self.delegate?.showError(text: error)
            self.delegate?.hideProgress()
            self.delegate?.fetchFinished()
            print(error)
        } progress: { progress in
            self.delegate?.didChangeProgress(progress: progress)
        }
    }
    
}


