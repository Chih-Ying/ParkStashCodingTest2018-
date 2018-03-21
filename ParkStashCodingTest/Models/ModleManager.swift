//
//  ModleManager.swift
//  ParkStashCodingTest
//
//  Created by ChihYing on 3/20/18.
//  Copyright © 2018 ChihYing. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class ModelManager: NSObject {
    
    var annotationModels: [AnnotationModel] = []
    private var managedObject: [NSManagedObject] = []
    
    override init() {
        super.init()
        self.fetch()
    }
    
    func save(model: AnnotationModel) {
        
        print("model ",model)
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Annotation", in: managedContext)
        let annotation = NSManagedObject(entity: entity!, insertInto: managedContext)
        annotation.setValue(model.title, forKey: "title")
        annotation.setValue(model.subtitle, forKey: "subtitle")
        annotation.setValue(model.latitude, forKey: "latitude")
        annotation.setValue(model.logitude, forKey: "logitude")
        
        do {
            try managedContext.save()
            annotationModels.append(model)
        } catch let error as NSError {
            print("Fail to save ", error)
        }
    }
    
    private func fetch(){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Annotation")
        
        do {
            managedObject = try managedContext.fetch(fetchRequest)
            
            for item in managedObject {
                let model = AnnotationModel(title: item.value(forKey: "title") as! String,
                                            subtitle: item.value(forKey: "subtitle") as! String,
                                            latitude: item.value(forKey: "latitude") as! Double,
                                            logitude: item.value(forKey: "logitude") as! Double)
                annotationModels.append(model)
            }
        } catch let error as NSError {
            print("Failed to fetch items", error)
        }
    }
    
}
