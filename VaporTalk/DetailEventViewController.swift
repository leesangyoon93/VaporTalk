//
//  DetailEventViewController.swift
//  VaporTalk
//
//  Created by 이상윤 on 2017. 5. 19..
//  Copyright © 2017년 이상윤. All rights reserved.
//

import UIKit
import MapKit
import FirebaseStorageUI
import Firebase

class DetailEventViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var eventImgView: UIImageView!
    @IBOutlet weak var eventMapKit: MKMapView!
    @IBOutlet weak var remainEventTimerLabel: UILabel!
    @IBOutlet weak var eventTimestampLabel: UILabel!
    @IBOutlet weak var eventLocationLabel: UILabel!
    
    var event: Event?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUI()
        eventMapKit.delegate = self
    }
    
    func setUI() {
        self.navigationItem.title = "\((event?.hostName)!)"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "back_white"), style: .plain, target: self, action: #selector(backButtonTouched))
        
        eventLocationLabel.text = event?.location
        eventTimestampLabel.text = event?.timestamp
        remainEventTimerLabel.text = event?.getRemainTime()
        setEventImage()
        setEventMap()
        eventImgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(detailEventImageTouched)))
    }
    
    func detailEventImageTouched() {
        self.performSegue(withIdentifier: "DetailEventImageSegue", sender: eventImgView.image)
    }
    
    func setEventImage() {
        let storage = FIRStorage.storage()
        let imageRef = storage.reference(withPath: "event/\((event?.hostUID)!)/\((event?.imageUrl)!)")
        eventImgView.sd_setImage(with: imageRef, placeholderImage: #imageLiteral(resourceName: "NoImageAvailable"))
    }
    
    func setEventMap() {
        let annotation = MKPointAnnotation()
        let location: CLLocationCoordinate2D = CLLocationCoordinate2DMake((event?.latitude!)!, (event?.longtitude!)!)
        
        let region = MKCoordinateRegionMakeWithDistance(location, 500, 500)
        self.eventMapKit.setRegion(region, animated: true)
        
        annotation.coordinate = location
        annotation.title = event?.title
        annotation.subtitle = event?.content
        
        eventMapKit.addAnnotation(annotation)
        eventMapKit.selectAnnotation(annotation, animated: true)
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
    
    func backButtonTouched() {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DetailEventImageSegue" {
            (segue.destination as! DetailImageViewController).detailImg = sender as? UIImage
        }
    }

}
