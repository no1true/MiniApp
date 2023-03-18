//
//  CardOnFileRepository.swift
//  MiniApp
//
//  Created by no1true on 2023/03/18.
//

import Foundation

protocol CardOnFileRepository {
    var cardOnFile: ReadOnlyCurrentValuePublisher<[PaymentMethod]> { get }
}

final class CardOnFileRepositoryImp: CardOnFileRepository {
    var cardOnFile: ReadOnlyCurrentValuePublisher<[PaymentMethod]>{ paymentMethodSubject }
    
    private let paymentMethodSubject = CurrentValuePublisher<[PaymentMethod]> ([
        PaymentMethod(id: "0", name: "우리은행", digits: "0123", color: "#f19a38ff", isPrimary: false),
        PaymentMethod(id: "1", name: "신한카드", digits: "0124", color: "#3478f6ff", isPrimary: false),
        PaymentMethod(id: "2", name: "현대카드", digits: "0125", color: "#78c5f5ff", isPrimary: false),
        PaymentMethod(id: "3", name: "국민은행", digits: "0126", color: "#65c466ff", isPrimary: false),
        PaymentMethod(id: "4", name: "카카오뱅크", digits: "0127", color: "#ffcc00ff", isPrimary: false)
    ])
}
