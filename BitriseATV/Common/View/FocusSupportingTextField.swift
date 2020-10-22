//
//  SkilledTextField.swift
//  BitriseATV
//
//  Created by Vladislav Sosiuk on 08.10.2020.
//  Copyright © 2020 Bitrise. All rights reserved.
//

import SwiftUI
import UIKit

class UIFocusSupportingTextField: UITextField {
    
    var placeholderColor: ((Bool) -> UIColor)?
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocus(in: context, with: coordinator)
        let focused = context.nextFocusedView === self
        let color = placeholderColor?(focused) ?? UIColor.black
        DispatchQueue.main.async {
            self.attributedPlaceholder = NSAttributedString(string: self.placeholder ?? "",
                                                            attributes:  [.foregroundColor: color,
                                                                          .font: self.font!])
        }
    }
}

struct FocusSupportingTextField: UIViewRepresentable {
    
    let placeholder: String
    @Binding var text: String
    let keyboardType: UIKeyboardType
    let font: UIFont
    let placeholderColor: ((Bool) -> UIColor)
    let onCommit: () -> Void
    
    func makeUIView(context: Context) -> UIFocusSupportingTextField {
        let textField = UIFocusSupportingTextField()
        textField.placeholderColor = placeholderColor
        textField.setContentHuggingPriority(.required, for: .vertical)
        textField.addTarget(context.coordinator, action: #selector(Coordinator.textChanged(sender:)), for: .editingChanged)
        textField.placeholder = placeholder
        textField.keyboardType = keyboardType
        textField.delegate = context.coordinator
        textField.font = font
        
        return textField
    }
    
    func updateUIView(_ textField: UIFocusSupportingTextField, context: Context) {
        textField.placeholder = placeholder
        textField.text = text
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(textField: self)
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        let textField: FocusSupportingTextField
        
        init(textField: FocusSupportingTextField) {
            self.textField = textField
        }
        
        @objc func textChanged(sender: UITextField) {
            textField.text = sender.text ?? ""
        }
        
        func textFieldDidEndEditing(_ textField: UITextField) {
            self.textField.onCommit()
        }
    }
}

