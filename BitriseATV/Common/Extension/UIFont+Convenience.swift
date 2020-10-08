//
//  UIFont+Convenience.swift
//  BitriseATV
//
//  Created by Vladislav Sosiuk on 08.10.2020.
//  Copyright © 2020 Bitrise. All rights reserved.
//

import UIKit

extension UIFont {
    private static func string(fromWeight weight: UIFont.Weight) -> String {
        switch weight {
        case .regular:
            return "Regular"
        default:
            return "Regular"
        }
    }
    
    static func proxima(weight: UIFont.Weight, size: CGFloat) -> UIFont {
        UIFont(name: "ProximaNova-\(string(fromWeight: weight))", size: size)!
    }
}
