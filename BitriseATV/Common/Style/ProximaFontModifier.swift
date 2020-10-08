//
//  ProximaFontModifier.swift
//  BitriseATV
//
//  Created by Vladislav Sosiuk on 18.09.2020.
//  Copyright © 2020 Bitrise. All rights reserved.
//

import SwiftUI

struct ProximaFontModifier: ViewModifier {
    var size: CGFloat
    var weight: Font.Weight
    
    private var weightString: String {
        switch weight {
        case .regular:
            return "Regular"
        default:
            return "Regular"
        }
    }

    func body(content: Content) -> some View {
        content
            .font(.proxima(weight: weight, size: size))
    }
}

extension View {
    func proximaFont(size: CGFloat, weight: Font.Weight) -> some View {
        self.modifier(ProximaFontModifier(size: size, weight: weight))
    }
}
