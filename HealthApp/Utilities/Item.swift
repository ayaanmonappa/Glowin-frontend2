//
//  Item.swift
//  HealthApp
//
//  Created by Ayaan Monappa on 29/3/24.
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
