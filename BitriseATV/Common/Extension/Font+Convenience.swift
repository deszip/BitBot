//
//  Font+Convenience.swift
//  BitriseATV
//
//  Created by Vladislav Sosiuk on 08.10.2020.
//  Copyright © 2020 Bitrise. All rights reserved.
//

import SwiftUI

extension Font {
    private static func string(fromWeight weight: Font.Weight) -> String {
        switch weight {
        case .regular:
            return "Regular"
        default:
            return "Regular"
        }
    }
    
    static func proxima(weight: Font.Weight, size: CGFloat) -> Font {
        .custom("ProximaNova-\(string(fromWeight: weight))", size: size)
    }
}
