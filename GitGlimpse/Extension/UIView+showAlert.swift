//
//  UIView+showAlert.swift
//  GitGlimpse
//
//  Created by Hoda Elnaghy on 10/26/23.
//

import UIKit

extension UIViewController {
    func show(errorAlert error: NSError) {
        show(error.localizedDescription)
    }
    
    func show(messageAlert title: String, message: String? = "", actionTitle: String? = nil, action: ((UIAlertAction) -> Void)? = nil, actionTitle2: String? = nil, action2: ((UIAlertAction) -> Void)? = nil) {
        show(title, 
             message: message,
             actionTitle: actionTitle,
             action: action,
             actionTitle2: actionTitle2,
             action2: action2)
    }
    
    fileprivate func show(_ title: String, message: String? = "", actionTitle: String? = nil, action: ((UIAlertAction) -> Void)? = nil, actionTitle2: String? = nil, action2: ((UIAlertAction) -> Void)? = nil) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if let closeAction = actionTitle2 {
            alert.addAction(UIAlertAction(title: closeAction, style: .default, handler: action2))
        }
        
        if let _actionTitle = actionTitle {
            alert.addAction(UIAlertAction(title: _actionTitle, style: .default, handler: action))
        }
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
}
