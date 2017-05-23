//
//  AnonymousUpdateDelegate.swift
//  VaporTalk
//
//  Created by 이상윤 on 2017. 5. 19..
//  Copyright © 2017년 이상윤. All rights reserved.
//

import Foundation

protocol AnonymousUpdateDelegate {
    func didUpdate(_ anonymousList: [Anonymous], _ contacts: [Anonymous])
}
