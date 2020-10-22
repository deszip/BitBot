//
//  UIColor+Focus.swift
//  BitriseATV
//
//  Created by Vladislav Sosiuk on 08.10.2020.
//  Copyright © 2020 Bitrise. All rights reserved.
//

import SwiftUI
import UIKit

extension UIColor {
    func resolvedColor(for colorScheme: ColorScheme, focused: Bool) -> UIColor {
        let userInterfaceStyle: UIUserInterfaceStyle
        switch colorScheme {
        case .dark:
            userInterfaceStyle = focused ? .light : .dark
        case .light:
            userInterfaceStyle = focused ? .dark : .light
        @unknown default:
            userInterfaceStyle = .light
        }
        let traitCollection = UITraitCollection(userInterfaceStyle: userInterfaceStyle)
        return resolvedColor(with: traitCollection)
    }
}
