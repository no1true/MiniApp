//
//  PaymentMethodViewModel.swift
//  MiniApp
//
//  Created by no1true on 2023/03/18.
//

import UIKit

struct PaymentMethodViewModel {
    let name: String
    let digits: String
    let color: UIColor
    
    init(_ paymentMethod: PaymentMethod) {
        name = paymentMethod.name
        digits = "**** \(paymentMethod.digits)"
        color = UIColor(hex: paymentMethod.color) ?? .systemGray
    }
}
