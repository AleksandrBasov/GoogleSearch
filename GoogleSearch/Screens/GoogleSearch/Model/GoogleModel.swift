//
//  Model.swift
//  GoogleSearch
//
//  Created by Александр Басов on 12/16/21.
//

import Foundation

struct Result: Codable {
    let kind : String?
    let items : [Item]
}

struct Item : Codable {
    let title : String?
    let link : String?
    let snippet : String?
}

