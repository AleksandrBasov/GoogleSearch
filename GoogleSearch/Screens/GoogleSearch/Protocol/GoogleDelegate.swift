//
//  GoogleDelegate.swift
//  GoogleSearch
//
//  Created by Александр Басов on 12/16/21.
//

import UIKit

protocol GoogleDelegate: AnyObject {
    func scrollViewDidScroll(y: CGFloat)
    func didTapOnItem(url: URL)
    func didChangeProgress(progress: Progress)
    func showProgress()
    func hideProgress()
    func showError(text: String)
    func fetchFinished()
}
