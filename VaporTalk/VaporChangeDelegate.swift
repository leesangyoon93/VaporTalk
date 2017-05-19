//
//  OnVaporChangeListener.swift
//  VaporTalk
//
//  Created by 이상윤 on 2017. 4. 18..
//  Copyright © 2017년 이상윤. All rights reserved.
//

protocol VaporListChangeDelegate {
    func didChange(_ vapors: [String:[Vapor]])
}
