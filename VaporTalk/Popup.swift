//
//  Popup.swift
//  VaporTalk
//
//  Created by 이상윤 on 2017. 4. 14..
//  Copyright © 2017년 이상윤. All rights reserved.
//

import PopupDialog

final class Popup: NSObject {
    
    public static func newPopup(_ title: String, _ message: String) -> PopupDialog {
        let popup = PopupDialog(title: title, message: message, buttonAlignment: .horizontal, transitionStyle: .zoomIn, gestureDismissal: true) { }
        return popup
    }
    
    public static func newImagePopup(_ title: String, _ message: String, _ image: UIImage) -> PopupDialog {
        let dialogAppearance = PopupDialogDefaultView.appearance()
        
        dialogAppearance.backgroundColor      = UIColor.white
        dialogAppearance.titleFont            = UIFont.boldSystemFont(ofSize: 17)
        dialogAppearance.titleColor           = UIColor(white: 0.4, alpha: 1)
        dialogAppearance.titleTextAlignment   = .center
        dialogAppearance.messageFont          = UIFont.systemFont(ofSize: 15)
        dialogAppearance.messageColor         = UIColor(white: 0.6, alpha: 1)
        dialogAppearance.messageTextAlignment = .center
        
        let popup = PopupDialog(title: title, message: message, image: image)
        return popup
    }
}
