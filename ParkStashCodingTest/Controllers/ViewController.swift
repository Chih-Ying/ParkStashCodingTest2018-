//
//  ViewController.swift
//  ParkStashCodingTest
//
//  Created by ChihYing on 3/19/18.
//  Copyright © 2018 ChihYing. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController {
    
    @IBOutlet weak var sideMenuView: UIView!
    @IBOutlet weak var sideMenuViewWidth: NSLayoutConstraint!
    @IBOutlet weak var sideMenuLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var mapVIew: MKMapView!
    
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var rating: UILabel!
    
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var menuTableView: UITableView!
    
    var sideMenuWidth: CGFloat!
    var modelManager: ModelManager!
    
    let menuItems = [["Book a Spot", "List a Spot", "Past Booking"],
                     ["Payment", "Promos", "Wallet","My Profile", "Ratings"],
                     ["Help", "Legal", "Logout"]];
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        modelManager = ModelManager()
        _setMapViewAnootations()
        _setSideMenuLayout()
        _setProfile()
    }
   
    
    @IBAction func tapMenu(_ sender: Any) {
        if sideMenuLeadingConstraint.constant < 0 {
            _openSideMenu()
        } else {
            _closeSideMenu()
        }
    }
    
    @IBAction func swipeAction(_ sender: UIPanGestureRecognizer) {
        
        if sender.state == .began || sender.state == .changed {
            let swipingRange = sender.translation(in: self.view).x
            if swipingRange > 0 { // swipw right
                if sideMenuLeadingConstraint.constant < 10 {
                    UIView.animate(withDuration: 0.2, animations: {
                        self.sideMenuLeadingConstraint.constant += swipingRange/10
                        self.view.layoutIfNeeded()
                    })
                }
            } else { // swipw left
                if sideMenuLeadingConstraint.constant > -sideMenuWidth {
                    UIView.animate(withDuration: 0.2, animations: {
                        self.sideMenuLeadingConstraint.constant += swipingRange/10
                        self.view.layoutIfNeeded()
                    })
                }
            }
        } else if sender.state == .ended {
            if sideMenuLeadingConstraint.constant < -100 {
                _closeSideMenu()
            } else {
                _openSideMenu()
            }
        }
    }
    
    private func _openSideMenu() {
        UIView.animate(withDuration: 0.4, animations: {
            self.sideMenuLeadingConstraint.constant = 0
            self.view.layoutIfNeeded()
        })
    }
    
    private func _closeSideMenu() {
        UIView.animate(withDuration: 0.4, animations: {
            self.sideMenuLeadingConstraint.constant = -self.sideMenuWidth
            self.view.layoutIfNeeded()
        })
    }
    
    private func _setMapViewAnootations() {
        for annotation in modelManager.annotationModels {
            // create annotation
            let annotation = AnnotationPin(title: annotation.title,
                                           subtitle: annotation.subtitle,
                                           coordinate: CLLocationCoordinate2DMake(annotation.latitude, annotation.logitude))
            mapVIew.addAnnotation(annotation)
        }
    }
    
    private func _setSideMenuLayout() {
        sideMenuWidth = self.view.frame.size.width * (2/3)
        sideMenuViewWidth.constant = sideMenuWidth
        sideMenuLeadingConstraint.constant = -sideMenuWidth
        
        sideMenuView.layer.shadowColor = UIColor.black.cgColor
        sideMenuView.layer.shadowOpacity = 0.5
        sideMenuView.layer.shadowOffset = CGSize(width: 5, height: 0 )
    }
    
    private func _setProfile() {
        userName.text = "Hello, Sameer !"
        rating.text = "5.0"
        avatar.layer.cornerRadius = avatar.frame.size.width / 2
        avatar.layer.masksToBounds = true
    }

}

extension ViewController: UISearchBarDelegate {
    
    @IBAction func searchAction(_ sender: Any) {
       let serachController = UISearchController(searchResultsController: nil)
        serachController.searchBar.delegate = self
        present(serachController, animated: true, completion: nil)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        // Avtivety Indicator
        let indicator = UIActivityIndicatorView()
        indicator.activityIndicatorViewStyle = .gray
        indicator.center = view.center
        indicator.hidesWhenStopped = true
        indicator.startAnimating()
        
        view.addSubview(indicator)
        
        // show keyboard and hide search bar
        searchBar.resignFirstResponder()
        dismiss(animated: true, completion: nil)
        
        // search request
        let searchRequest = MKLocalSearchRequest()
        searchRequest.naturalLanguageQuery = searchBar.text
        
        let activeSearch = MKLocalSearch(request: searchRequest)
        activeSearch.start { (response, error) in
            
            indicator.stopAnimating()

            if response == nil {
                let alert = UIAlertController(title: "Cannot find the location out!", message: "Please try again!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else {
                
                let latitude = response?.boundingRegion.center.latitude
                let longitude = response?.boundingRegion.center.longitude
                
                // Zooming in the location
                let coordinate = CLLocationCoordinate2DMake(latitude!, longitude!)
                let span = MKCoordinateSpanMake(0.1, 0.1)
                let region = MKCoordinateRegionMake(coordinate, span)
                self.mapVIew.setRegion(region, animated: true)
                
                // Confirmation alert
                let alert = UIAlertController(title: "Pin \(searchBar.text!) to Map?", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                alert.addTextField(configurationHandler: { (textField) in
                    textField.placeholder = "Feel free to input subtitle here..."
                })
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    
                    // create annotation
                    let annotation = AnnotationPin(title: searchBar.text!,
                                                   subtitle: (alert.textFields?.first?.text)!,
                                                   coordinate: CLLocationCoordinate2DMake(latitude!, longitude!))
                    self.mapVIew.addAnnotation(annotation)
                    
                    // save annotation
                    let model = AnnotationModel(title: searchBar.text!,
                                                subtitle: (alert.textFields?.first?.text)!,
                                                latitude: latitude!,
                                                logitude: longitude!)
                    self.modelManager.save(model: model)
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems[section].count;
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return menuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "menuCell")
        cell?.textLabel?.text = menuItems[indexPath.section][indexPath.row]
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }
    

}

extension ViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
        if (touch.view?.isDescendant(of: mapVIew))! {
            _closeSideMenu()
        }
        return true
    }
    
}

