//
//  RegisterCompleteDelegate.swift
//  VaporTalk
//
//  Created by 이상윤 on 2017. 5. 23..
//  Copyright © 2017년 이상윤. All rights reserved.
//

import Foundation

protocol RegisterSuccessDelegate {
    func didSuccess(_ userData: [String: String], _ profileData: Data)
}
