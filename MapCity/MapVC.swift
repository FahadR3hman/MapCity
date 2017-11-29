//
//  ViewController.swift
//  MapCity
//
//  Created by Fahad Rehman on 11/28/17.
//  Copyright © 2017 Codecture. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import MapKit
class MapVC: UIViewController  , MKMapViewDelegate , CLLocationManagerDelegate , UIGestureRecognizerDelegate , UICollectionViewDelegate , UICollectionViewDataSource{
    
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var buttonHeight: NSLayoutConstraint!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var hiddenView: UIView!
    
    var locationManger = CLLocationManager()
    let authorizationStatus = CLLocationManager.authorizationStatus()
    let regionRadius : Double = 1000
    
    var spinner : UIActivityIndicatorView?
    var progressLabel : UILabel?
    var screenSize = UIScreen.main.bounds
    var collectionView : UICollectionView?
    var flowLayOut : UICollectionViewFlowLayout?
    
    var imageUrlArray = [String]()
    var ImageArray = [UIImage]()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        map.delegate = self
        locationManger.delegate = self
        configureLocationServices ()
        addDoubleTap()
        flowLayOut = UICollectionViewFlowLayout()
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayOut!)
        collectionView?.register(PhotoCell.self, forCellWithReuseIdentifier: "cell")
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        hiddenView.addSubview(collectionView!)
    }
    
    func configureLocationServices () {
        if (authorizationStatus == .notDetermined) {
            
            locationManger.requestAlwaysAuthorization()
        } else {
            return
        }
        
    }
    
    
    func centerMapOnUserLocation () {
        guard let coordinate = locationManger.location?.coordinate else { return }
        
        
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(coordinate, regionRadius * 2.0 , regionRadius * 2.0 )
        map.setRegion(coordinateRegion, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        centerMapOnUserLocation()
    }
    
    @IBAction func centerPressed(_ sender: Any) {
        if (authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse) {
            centerMapOnUserLocation()
            
        }
        
        
    }
    
    func addDoubleTap () {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(dropPin(sender: )))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        map.addGestureRecognizer(doubleTap)
    }
    
    func swipeGesture () {
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(animateViewDown))
        swipe.direction = .down
        
        hiddenView.addGestureRecognizer(swipe)
    }
    
    func addSpinner () {
        spinner = UIActivityIndicatorView()
        spinner?.center = CGPoint(x: (screenSize.width / 2) - ((spinner?.frame.width)! / 2), y: 150)
        spinner?.activityIndicatorViewStyle = .whiteLarge
        spinner?.color = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        spinner?.startAnimating()
        collectionView?.addSubview(spinner!)
    }
    
    func removeSpinner () {
        if spinner != nil {
            spinner?.removeFromSuperview()
        }
    }
    func removeLabel () {
        if progressLabel != nil {
            progressLabel?.removeFromSuperview()
        }
    }
    func addProgressLbl () {
        progressLabel = UILabel()
        progressLabel?.frame = CGRect(x: (screenSize.width / 2 ) - 120.0 , y: 175, width: 240, height: 50)
        progressLabel?.font = UIFont(name: "Avenir Next", size: 18)
        
        progressLabel?.textAlignment = .center
        collectionView?.addSubview(progressLabel!)
    }
    
    @objc func dropPin (sender : UITapGestureRecognizer) {
        RemovePin()
        removeSpinner()
        removeLabel()
        cancelAllSessions()
        animateViewUp()
        swipeGesture()
        addSpinner()
        addProgressLbl()
        
       
        let touchpoint = sender.location(in: map)
        let touchCoordinate = map.convert(touchpoint, toCoordinateFrom: map)
        let annotation = DroppablePin(coordiante: touchCoordinate, identifier: "DroppablePin")
        map.addAnnotation(annotation)

        let coordinateRegion = MKCoordinateRegionMakeWithDistance(touchCoordinate,regionRadius * 2.0 , regionRadius * 2.0)
        
        
        map.setRegion(coordinateRegion, animated: true)
        
        downloadUrls(annotation: annotation) { (done) in
            if done {
                self.downloadImages(handler: { (done) in
                    if done {
                        self.removeLabel()
                        self.removeSpinner()
                      //  self. collectionView?.reloadData()
                    }
                })
            }
            
            print(self.imageUrlArray)
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if (annotation is MKUserLocation) {
            return nil
        }
        
        let pinAnnotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "DroppablePin")
        pinAnnotation.pinTintColor = #colorLiteral(red: 0.9771530032, green: 0.7062081099, blue: 0.1748393774, alpha: 1)
        pinAnnotation.animatesDrop = true
        return pinAnnotation
    }
    
    func animateViewUp() {
        heightConstraint.constant = 300
        buttonHeight.constant = -320
        
        UIView.animate(withDuration: 0.3) {
            print("Animating")
            self.view.layoutIfNeeded()
        }
        
    }
    
    @objc func animateViewDown() {
        print("Animating Down")
        heightConstraint.constant = 1
        buttonHeight.constant = -20
        cancelAllSessions()
        UIView.animate(withDuration: 0.2 ) {
            
            self.view.layoutIfNeeded()
        }
    }
    
    func RemovePin () {
        for annotation in map.annotations {
            map.removeAnnotation(annotation)
            
        }
    }
    
    
    //MARK: CollectionView Functions
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ImageArray.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? PhotoCell else {
        return UICollectionViewCell()
            
        }
        return cell
    }
    
    //MARK: Photos Functions\
    func downloadUrls (annotation : DroppablePin , handler : @escaping (_ status : Bool)  -> ()) {
        imageUrlArray = []
        Alamofire.request(FLIKER_URL(forApiKey: API_KEY, forAnnotation: annotation, numOfPhotos: 40)).responseJSON { (response) in
            if response.result.error == nil {
                guard let JSON = response.result.value as? Dictionary<String, Any> else { return }
                guard let photos = JSON["photos"] as? Dictionary <String , Any> else {
                    return
                }
                guard let photoDict = photos["photo"] as? [Dictionary<String, Any>] else {
                    return
                }
                for photo in photoDict {
                    let urls = "https://farm\(photo["farm"]!).staticflickr.com/\(photo["server"]!)/\(photo["id"]!)_\(photo["secret"]!)_h_d.jpg"
                    
                    self.imageUrlArray.append(urls)
                }
              handler(true)
            } else {
                print(response.result.error.debugDescription)
            }
        }
    }
    func downloadImages(handler : @escaping (_ status : Bool)  -> ()) {
        ImageArray = []
        
        for url in imageUrlArray {
            Alamofire.request(url).responseImage(completionHandler: { (response) in
                guard let image = response.result.value else { return }
                self.ImageArray.append(image)
                self.progressLabel?.text = "\(self.ImageArray.count)/40 Images Downloaded"
                
                if (self.ImageArray.count == self.imageUrlArray.count){
                   
                    handler(true)
                }
            })
        }
    }
    func cancelAllSessions() {
        Alamofire.SessionManager.default.session.getTasksWithCompletionHandler { (sessionDataTask, uploadDataTask, downloadDataTask) in
            sessionDataTask.forEach({ $0.cancel() })
            downloadDataTask.forEach({$0.cancel() })
        }
    }
}












