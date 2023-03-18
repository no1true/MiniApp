//
//  PaymentMethod.swift
//  MiniApp
//
//  Created by no1true on 2023/03/18.
//

import Foundation

struct PaymentMethod: Decodable {
    let id: String
    let name: String
    let digits: String
    let color: String
    let isPrimary: Bool
    
}
