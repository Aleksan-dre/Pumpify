//
// UIViewController+Extensions.swift//  Pumpify
//
//  Created by Aleksandre Shalikashvili on 12.05.25.
//

import UIKit

extension UIViewController {
    static func getRootViewController() -> UIViewController {
        guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return UIViewController()
        }
        
        guard let root = screen.windows.first?.rootViewController else {
            return UIViewController()
        }
        
        return root
    }
}
