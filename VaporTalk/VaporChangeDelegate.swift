//
//  OnVaporChangeListener.swift
//  VaporTalk
//
//  Created by 이상윤 on 2017. 4. 18..
//  Copyright © 2017년 이상윤. All rights reserved.
//

@objc
protocol VaporChangeDelegate {
    @objc optional func didChange()
    @objc optional func didUpdated()
}
