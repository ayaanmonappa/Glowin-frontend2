//
//  ModalType.swift
//  HealthApp
//
//  Created by Ayaan Monappa on 6/6/24.
//

import Foundation

enum ModalType: Identifiable {
    var id: String {
        switch self {
        case .add: return "add"
        case .update: return "update"
        }
    }
    
    case add
    case update(Measurement)
}

