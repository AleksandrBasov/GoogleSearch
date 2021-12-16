//
//  UIViewController+Alert.swift
//  GoogleSearch
//
//  Created by Александр Басов on 12/16/21.
//

import UIKit

extension UIViewController {
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Connection error:", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
}
