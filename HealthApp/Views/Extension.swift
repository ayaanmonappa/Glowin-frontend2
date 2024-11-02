//
//  Extension.swift
//  HealthApp
//
//  Created by Ayaan Monappa on 29/3/24.
//

import Foundation
import SwiftUI
import UIKit


extension Color {



        // Use a different naming convention or avoid common names to prevent conflicts
        static let customBackground = Color("Background")
        static let customIcon = Color("Icon")
        static let customText = Color("Text")
        
        // Use a different name for systemBackground or provide context
        static let customSystemBackground = Color(UIColor.systemBackground)
 
            
        
    

    
    //static, all instances of Color share background. let is for constants, cannot be changed like a variable
}
#Preview {
    OpeningPage()
        .modelContainer(for: Item.self, inMemory: true)
}
