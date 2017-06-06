//
//  CommerceAnalysis.swift
//  VaporTalk
//
//  Created by 이상윤 on 2017. 5. 21..
//  Copyright © 2017년 이상윤. All rights reserved.
//

import Foundation

struct CommerceAnalysis {
    let category: String?
    let item: String?
    let categoryDivision: String?
    let price: Int
    
    init(category: String, item: String, categoryDivision: String, price: Int) {
        self.category = category
        self.item = item
        self.categoryDivision = categoryDivision
        self.price = price
    }
}
