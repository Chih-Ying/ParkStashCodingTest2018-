//
//  ViewController.swift
//  ParkStashCodingTest
//
//  Created by ChihYing on 3/19/18.
//  Copyright © 2018 ChihYing. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var sideMenuView: UIView!
    @IBOutlet weak var sideMenuViewWidth: NSLayoutConstraint!
    @IBOutlet weak var sideMenuLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var rating: UILabel!
    
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var menuTableView: UITableView!
    
    var sideMenuWidth: CGFloat!
    
    let menuItems = [["Book a Spot", "List a Spot", "Past Booking"],
                     ["Payment", "Promos", "Wallet","My Profile", "Ratings"],
                     ["Help", "Legal", "Logout"]];
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sideMenuWidth = self.view.frame.size.width * (2/3)
        sideMenuViewWidth.constant = sideMenuWidth
        sideMenuLeadingConstraint.constant = -sideMenuWidth

        _setProfile()
    }

    @IBAction func swipeAction(_ sender: UIPanGestureRecognizer) {
        
        // referance : https://www.youtube.com/watch?v=ISxe1Fq-tTw
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
                UIView.animate(withDuration: 0.4, animations: {
                    self.sideMenuLeadingConstraint.constant = -self.sideMenuWidth
                    self.view.layoutIfNeeded()
                })
            } else {
                UIView.animate(withDuration: 0.4, animations: {
                    self.sideMenuLeadingConstraint.constant = 0
                    self.view.layoutIfNeeded()
                })
            }
            
        }
        
    }
    
    @IBAction func tapMenu(_ sender: Any) {
        
        if sideMenuLeadingConstraint.constant < 0 {
            UIView.animate(withDuration: 0.4, animations: {
                self.sideMenuLeadingConstraint.constant = 0
                self.view.layoutIfNeeded()
            })
        }
        
    }
    
    private func _setProfile() {
        userName.text = "Hello, Sameer !"
        rating.text = "5.0"
        
        avatar.layer.cornerRadius = avatar.frame.size.width / 2
        avatar.layer.masksToBounds = true
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


