//
//  DetailCommerceViewController.swift
//  VaporTalk
//
//  Created by 이상윤 on 2017. 5. 21..
//  Copyright © 2017년 이상윤. All rights reserved.
//

import UIKit
import MapKit
import FirebaseStorageUI
import Firebase

class DetailCommerceViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var commerceTimestampLabel: UILabel!
    @IBOutlet weak var commerceTimerLable: UILabel!
    @IBOutlet weak var commerceMapKit: MKMapView!
    @IBOutlet weak var commerceImgView: UIImageView!
    @IBOutlet weak var commerceLocationLabel: UILabel!
    
    var commerce: Event?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        commerceMapKit.delegate = self
        setUI()
    }
    
    func setUI() {
        self.navigationItem.title = "\((commerce?.hostName)!)"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backButtonTouched))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "구매확인", style: .plain, target: self, action: #selector(buyCheckButtonTouched))
        commerceLocationLabel.text = commerce?.location
        commerceTimestampLabel.text = commerce?.timestamp
        commerceTimerLable.text = commerce?.getRemainTime()
        setCommerceImage()
        setCommerceMap()
    }
    
    func setCommerceImage() {
        let storage = FIRStorage.storage()
        let imageRef = storage.reference(withPath: "commerce/\((commerce?.hostUID)!)/\((commerce?.imageUrl)!)")
        commerceImgView.sd_setImage(with: imageRef, placeholderImage: #imageLiteral(resourceName: "NoImageAvailable"))
    }
    
    func setCommerceMap() {
        let annotation = MKPointAnnotation()
        let location: CLLocationCoordinate2D = CLLocationCoordinate2DMake((commerce?.latitude!)!, (commerce?.longtitude!)!)
        
        let region = MKCoordinateRegionMakeWithDistance(location, 500, 500)
        self.commerceMapKit.setRegion(region, animated: true)
        
        annotation.coordinate = location
        annotation.title = commerce?.title
        annotation.subtitle = commerce?.content
        
        commerceMapKit.addAnnotation(annotation)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
        }
        else {
            pinView!.annotation = annotation
        }
        
        let subtitleView = UILabel()
        subtitleView.font = subtitleView.font.withSize(12)
        subtitleView.numberOfLines = 10
        subtitleView.text = annotation.subtitle!
        pinView!.detailCalloutAccessoryView = subtitleView
        
        return pinView
    }
    
    func buyCheckButtonTouched() {
        showBuyCheckDialog(title: "Password", message: "구매확인 비밀번호를 입력해주세요.")
    }
    
    func backButtonTouched() {
        self.dismiss(animated: true, completion: nil)
    }

    func showBuyCheckDialog(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        var passwordTextField = UITextField()
        
        alertController.addTextField { (textField) in
            textField.placeholder = "비밀번호"
            passwordTextField = textField
        }
        
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { (_) in
            if passwordTextField.text == self.commerce?.password {
                let commerceModel = CommerceModel()
                commerceModel.checkCommerce(self.commerce!)
                self.dismiss(animated: true, completion: nil)
            }
            else {
                self.showAlertDialog(title: "비밀번호 오류", message: "구매확인 비밀번호가 일치하지 않습니다")
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showAlertDialog(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "Close Alert", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
}
