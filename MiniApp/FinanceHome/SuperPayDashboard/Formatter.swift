//
//  Formatter.swift
//  MiniApp
//
//  Created by no1true on 2023/03/18.
//

import Foundation

struct Formatter {
    static let balanceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
}
