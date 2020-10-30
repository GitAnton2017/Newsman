//
//  File Manager Helpers RX.swift
//  Newsman
//
//  Created by Anton2016 on 05.04.2020.
//  Copyright © 2020 Anton2016. All rights reserved.
//

import Foundation
import RxSwift

extension FileManager
{
 static func createDirectoryOnDisk(at url: URL) -> Completable
 {
  Completable.create { promise in
   createDirectoryOnDisk(at: url)
   {
    switch $0
    {
     case .success():          promise(.completed)
     case .failure(let error): promise(.error(error))
    }
   }
   return Disposables.create()
  }
 }//static func createDirectoryOnDisk...
 
 
 static func moveItemOnDisk(from fromURL: URL, to toURL: URL) -> Completable
 {
  Completable.create{ promise in
   moveItemOnDisk(from: fromURL, to: toURL)
   {
    switch ($0.mapError{ FileError.moveFailure(from: fromURL, to: toURL, message: $0.localizedDescription) })
    {
     case .success():          promise(.completed)
     case .failure(let error): promise(.error(error))
    }
   }
   return Disposables.create()
  }
 }//static func moveItemOnDisk...
 
 
 
 static func batchMoveCompletable(using urlPairs: [(from: URL, to: URL)]) -> Completable
 {
  Observable.from(urlPairs).map{ (fromURL, toURL) in
   moveItemOnDisk(from: fromURL, to: toURL)
    .catchError { (error) -> Completable in
      switch error
      {
       case let error as FileError: print("{\(#function)} \(error.debugDescription)")
       default: break
      }
      return .empty()
    }
   }
   .merge()
   .asCompletable()
 }//static func batchMoveCompletable....
 
 
 
 static func removeItemFromDisk (at url: URL) -> Completable
 {
  Completable.create {promise in
   removeItemFromDisk(at: url)
   {
    switch ($0.mapError{ FileError.deleteFailure(at: url, message: $0.localizedDescription) })
    {
     case .success():          promise(.completed)
     case .failure(let error): promise(.error(error))
    }
   }
   return Disposables.create()
  }
 }
 
 
 
 static func batchDeleteCompletable(using urls: [URL]) -> Completable
 {
  Completable.zip(urls.map{ url in
   removeItemFromDisk(at: url)
   .catchError {(error) -> Completable in
     switch error
     {
      case let error as FileError: print("{\(#function)} \(error.debugDescription)")
      default: break
     }
     return .empty()
   }
  })
 }
 
 
}//extension FileManager....
