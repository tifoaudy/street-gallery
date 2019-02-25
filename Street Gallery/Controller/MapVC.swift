//
//  ViewController.swift
//  Street Gallery
//
//  Created by Tifo Audi Alif Putra on 19/02/19.
//  Copyright © 2019 BCC FILKOM. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapVC: UIViewController, UIGestureRecognizerDelegate {
    
    //outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var pullUpView: UIView!
    @IBOutlet weak var pullUpViewHeightConstraint: NSLayoutConstraint!
    
    //properties
    var locationManager = CLLocationManager()
    let status = CLLocationManager.authorizationStatus()
    let regionRadius: Double = 1000
    var spinner: UIActivityIndicatorView?
    var progressLabel: UILabel?
    var screenSize = UIScreen.main.bounds
    var photoCollection: UICollectionView?
    var flowLayout = UICollectionViewLayout()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.startUpdatingLocation()

        configureLocationServices()
        onDoubleTapHandle()
        
        photoCollection = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
        photoCollection?.register(PhotoCell.self, forCellWithReuseIdentifier: "photo_cell")
        photoCollection?.delegate = self
        photoCollection?.dataSource = self
        photoCollection?.backgroundColor = #colorLiteral(red: 1, green: 0.2429925799, blue: 0, alpha: 1)
        pullUpView.addSubview(photoCollection!)
    }
    
    func onDoubleTapHandle(){
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(dropPin(sender:)))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        mapView.addGestureRecognizer(doubleTap)
    }
    
    func onSwipeDown() {
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(animatePullDownView))
        swipe.direction = .down
        pullUpView.addGestureRecognizer(swipe)
    }
    
    func animatePullUpView() {
        pullUpViewHeightConstraint.constant = 300
        UIView.animate(withDuration: 0.3) {
            self.loadViewIfNeeded()
        }
    }
    
    func addSpinner() {
        spinner = UIActivityIndicatorView()
        spinner?.center = CGPoint(x: screenSize.width / 2, y: 150)
        spinner?.style = .whiteLarge
        spinner?.color = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        spinner?.startAnimating()
        photoCollection?.addSubview(spinner!)
    }
    
    func removeSpinner(){
        if spinner != nil {
            spinner?.removeFromSuperview()
        }
    }
    
    func addProgressLabel() {
        progressLabel = UILabel()
        progressLabel?.frame = CGRect(x: (screenSize.width/2) - 100, y: 175, width: 200, height: 40)
        progressLabel?.font = UIFont(name: "Avenir Next", size: 18)
        progressLabel?.textColor = #colorLiteral(red: 0.05882352963, green: 0.180392161, blue: 0.2470588237, alpha: 1)
        progressLabel?.textAlignment = .center
        progressLabel?.text = "Fetching Image"
        photoCollection?.addSubview(progressLabel!)
    }
    
    func removeProgressLabel() {
        if progressLabel != nil {
            progressLabel?.removeFromSuperview()
        }
    }
    
    @objc func animatePullDownView() {
        pullUpViewHeightConstraint.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.loadViewIfNeeded()
        }
    }
    
    //action
    @IBAction func locationBtnPressed(_ sender: Any) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            centerUserCoordinats()
        }
    }
}

extension MapVC: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation { return nil }
        
        let pinAnnotaion = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "drop_pin")
        pinAnnotaion.tintColor = #colorLiteral(red: 1, green: 0.2429925799, blue: 0, alpha: 1)
        pinAnnotaion.animatesDrop = true
        return pinAnnotaion
    }
    
    func centerUserCoordinats () {
        guard let userCoordinate = locationManager.location?.coordinate else { return }
        
        let coordinateRegion = MKCoordinateRegion(center: userCoordinate, latitudinalMeters: regionRadius * 2, longitudinalMeters: regionRadius * 2)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    @objc func dropPin(sender: UITapGestureRecognizer) {
        removeAllPins()
        removeSpinner()
        removeProgressLabel()
        
        animatePullUpView()
        onSwipeDown()
        addSpinner()
        addProgressLabel()
        
        let touchPoint = sender.location(in: mapView)
        let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        
        let annotation = DroppablePin(identifier: "drop_pin", coordinate: touchCoordinate)
        mapView.addAnnotation(annotation)
        
        let coordinateRegion = MKCoordinateRegion(center: touchCoordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func removeAllPins() {
        for annotation in mapView.annotations {
            mapView.removeAnnotation(annotation)
        }
    }
}

extension MapVC: CLLocationManagerDelegate {
    
    func configureLocationServices() {
        if status == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        } else {
            return
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        centerUserCoordinats()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        centerUserCoordinats()
    }
}

extension MapVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photo_cell", for: indexPath) as? PhotoCell {
            return cell
        }else {
            return PhotoCell()
        }
    }

}

