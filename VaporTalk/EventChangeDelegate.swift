//
//  EventChangeDelegate.swift
//  VaporTalk
//
//  Created by 이상윤 on 2017. 5. 18..
//  Copyright © 2017년 이상윤. All rights reserved.
//

import Foundation

protocol EventChangeDelegate {
    func didChange(_ events: [Event])
}
