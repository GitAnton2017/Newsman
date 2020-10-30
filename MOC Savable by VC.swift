//
//  MOC Savable by VC.swift
//  Newsman
//
//  Created by Anton2016 on 07.03.2020.
//  Copyright © 2020 Anton2016. All rights reserved.
//
/*  The protocol helper that adopted mainly by ViewControllers
 to get reference to global MOC and save context method */

import class UIKit.UIApplication
import class CoreData.NSManagedObjectContext
import class RxSwift.Observable

protocol ManagedObjectContextSavable
{
 var moc: NSManagedObjectContext { get }
}

extension ManagedObjectContextSavable
{
 func saveContext() { moc.perform { self.moc.saveIfNeeded() } }
}

/* conveniance property wrapper to inject MOC
 into classes uncluding ones that conform to above ManagedObjectContextSavable protocol */

@propertyWrapper class MOC
{
 private var context: NSManagedObjectContext

 var wrappedValue: NSManagedObjectContext
 {
  get { context }
  set { context = newValue }
 }
 
 init() // set once default MOC from current app persistentContainer.
 {
  let appDelegate = UIApplication.shared.delegate as! AppDelegate
  context = appDelegate.persistentContainer.viewContext
 }
 
 // to set up background MOCs if anu used in app...
 init(wrappedValue: NSManagedObjectContext)
 {
  self.context = wrappedValue
 }
 
 var projectedValue: Observable<NSManagedObjectContext> { .just(context) }
 
}
