//
//  File Manager Helpers Combine.swift
//  Newsman
//
//  Created by Anton2016 on 05.04.2020.
//  Copyright © 2020 Anton2016. All rights reserved.
//

import Foundation
import Combine

extension FileManager
{
 
 static func createDirectoryOnDisk(at url: URL) -> Future<Void, Error>
 {
  Future<Void, Error> { createDirectoryOnDisk(at: url, completion: $0) }
 }//static func createDirectoryOnDisk...
 
 static func moveItemOnDisk(from fromURL: URL, to toURL: URL) -> Future<Void, Error>
 {
  Future<Void, Error>
  {promise in
   moveItemOnDisk(from: fromURL, to: toURL, completion: promise)
  }
 }//static func moveItemOnDisk...
 
 static func batchMovePublisher(using urlPairs: [(from: URL, to: URL)]) -> AnyPublisher<Void, Error>
 {
  urlPairs.publisher
   .setFailureType(to: Error.self)
   .flatMap{(from, to) in
     moveItemOnDisk(from: from, to: to)
      .catch{ error -> Empty<Void, Error> in
        switch error
        {
         case let error as FileError: print("{\(#function)} \(error.debugDescription)")
         default: break
        }
        return Empty()
     }
  }.eraseToAnyPublisher()
 }//static func batchMovePublisher...
 
 static func removeItemFromDisk (at url: URL) -> Future<Void, Error>
 {
  Future<Void, Error>
  {promise in
    removeItemFromDisk(at: url, completion: promise)
  }
 }//static func removeItemFromDisk...
 
 static func batchDeletePublisher(using urls: [URL]) -> AnyPublisher<Void, Error>
 {
  urls.reduce(Empty().eraseToAnyPublisher())
  {result, url in
   result
    .merge(with: removeItemFromDisk(at: url)
     .catch{ error -> Empty<Void, Error> in
       switch error
       {
        case let error as FileError: print("{\(#function)} \(error.debugDescription)")
        default: break
       }
       return Empty()
     })
    .eraseToAnyPublisher()
  }
 }//static func batchDeletePublisher...

 
}//extension FileManger...
