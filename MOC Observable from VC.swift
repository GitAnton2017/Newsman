//
//  MOC Observable from VC.swift
//  Newsman
//
//  Created by Anton2016 on 07.03.2020.
//  Copyright © 2020 Anton2016. All rights reserved.
//

import class CoreData.NSManagedObjectContext

import class RxSwift.Observable

import struct Combine.Just
import struct Combine.Fail
import struct Combine.AnyPublisher

extension ManagedObjectContextObservable where Self:  ManagedObjectContextSavable
{
 var MOC$: Observable<NSManagedObjectContext> { .just(moc) }//RxSwift MOC observable
 
 var MOC$$: AnyPublisher<NSManagedObjectContext, Never> //Combine MOC Publisher...
 {
  Just(moc).eraseToAnyPublisher()
 }//extension ManagedObjectContextObservable....
 
}

