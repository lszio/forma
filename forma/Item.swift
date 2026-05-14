//
//  Item.swift
//  forma
//
//  Created by lszio on 2026/5/14.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
