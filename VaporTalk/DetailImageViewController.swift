//
//  DetailImageViewController.swift
//  VaporTalk
//
//  Created by 이상윤 on 2017. 5. 31..
//  Copyright © 2017년 이상윤. All rights reserved.
//

import UIKit

class DetailImageViewController: UIViewController {

    var detailImg: UIImage?
    @IBOutlet weak var detailImgView: UIImageView!
    @IBOutlet weak var backButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        detailImgView.image = detailImg!

        backButton.addTarget(self, action: #selector(backButtonTouched), for: .touchUpInside)
    }

    func backButtonTouched() {
        self.dismiss(animated: true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
