//
//  DragAndDropStatesObservation.swift
//  Newsman
//
//  Created by Anton2016 on 22.04.2020.
//  Copyright © 2020 Anton2016. All rights reserved.
//

import RxSwift
import class CoreData.NSManagedObject

protocol DragAndDropStatesRepresentable where Self: NSManagedObject
{
 var isDragProceeding: Bool   { get set } // not managed...
 var isDropProceeding: Bool   { get set } // not managed...
}

protocol DragAndDropStatesObservation: class
{
 var disposeBag: DisposeBag    { get }
 var completion: ( () -> () )? { get set }
 var name: String              { get }
}

extension DragAndDropStatesObservation
{
 
 var ddDelegateSubject: BehaviorSubject<DragAndDropDelegateStates>
 {
  (UIApplication.shared.delegate as! AppDelegate).dragAndDropDelegatesStatesSubject
 }
 
 func observeDragAndDropStates()
 {
  
  ddDelegateSubject
   .do(onNext: { [ weak self ] state in
     guard let self = self else { return }
     guard case let .drop (count, _) = state, count > 0 else { return }
     guard let completion = self.completion else { return }
     self.ddDelegateSubject
      .filter{ $0 == .final }
      .debug(" <<<< DRAGGED EVENT COUNT PUBLISHER (\(count)) IN: [\(self)] >>>>")
      .elementAt(count - 1) // terminates & disposed after receive count of elements!
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { _ in completion() })
      .disposed(by: self.disposeBag)
   })//FLOCKING....
   .compactMap { state -> Draggable? in
     guard case .flock(let dragged) = state else { return nil }
     dragged.dispose()
     (dragged as? PhotoFolderItem)?.singlePhotoItems.forEach{ $0.dispose() }
     dragged.isSelected = true
     dragged.isDragAnimating = true
     if (!AppDelegate
          .globalDragItems
          .contains{ $0.hostedManagedObject.objectID == dragged.hostedManagedObject.objectID })
     {
      AppDelegate.globalDragItems.append(dragged) //if all OK put it in drags first...
     }
     return dragged
  }
  .debug("<<<< DRAG AND DROP STATES (MAIN PUBLISHER) IN [\(self)] >>>>")
  .subscribe(onNext: { [weak self] in
   let dragged = $0
   guard let self = self else { return }
   dragged.dragStateSubscription = self.ddDelegateSubject
    .timeout(.seconds(10), scheduler: MainScheduler.instance)
    .observeOn(MainScheduler.instance)
    .do(onError: { [ weak dragged ] error in
      guard case RxError.timeout = error else { return }
      dragged?.terminate()
    })
    .do(onNext: { [ weak self, weak dragged ] state in
     guard let self = self else { return }
     switch state
     {
       case .drop:
        guard dragged?.dragSession != nil else { break }
        dragged?.isDropProceeding = true
        (dragged as? PhotoFolderItem)?.singlePhotoItems.forEach{ $0.clearAfterDrop() }
        fallthrough
      
       case .end:
        dragged?.isDragProceeding = false
        dragged?.dragProceedSubscription?.dispose()

       case .proceed where dragged?.dragProceedSubscription == nil:
        dragged?.dragProceedSubscription = self.ddDelegateSubject
         .compactMap { state -> DragAndDropDelegateStates? in
           guard case let .proceed(location) = state else { return nil }
           dragged?.dragProceedLocation = location
           return state
         }//.compactMap { state...
         .distinctUntilChanged()
         .do (onNext: { _ in dragged?.isDragProceeding = true })
         .debounce(.milliseconds(750), scheduler: MainScheduler.instance) //.debug("DRAG PROCEED")
         .subscribe(onNext: { _ in dragged?.isDragProceeding = false })
       
       default: break
      }
      
    })
    .filter{ $0 == .end  }
    .debug("DROPPED DRAG ITEM <\(dragged)> ID: [\(dragged.id?.uuidString ?? "NO ID")] IN DELEGATE [\(String(describing: self))]")
    .do(onNext:    { _ in dragged.removeFromDrags()        })
    .debounce(.seconds(3), scheduler: MainScheduler.instance)
    .do(onNext:    { _ in dragged.isDragAnimating = false  })
    .do(onNext:    { _ in dragged.isDropProceeding = false })
    //.do(onDispose: {      dragged.isSelected = false       })
    .flatMap{Observable.just($0)
                       .delay(.seconds(2), scheduler: MainScheduler.instance)
                       .do(onNext: { _ in
                         dragged.isSelected = false
                         dragged.dispose()
                        
                       })
     
    }
    .subscribe(onNext: { _ in let _ = self })
  }).disposed(by: disposeBag)
  
 }
}

extension Draggable
{
 func clearAfterDrop()
 {
  print (#function, self, self.id ?? "")
  
  if dragStateSubscription != nil
  {
   dispose()
   isDragAnimating = true
   isSelected = true
   isDragProceeding = true
   isDropProceeding = true
  }
  
  dragStateSubscription = Observable
   .just(self)
   .delay(.seconds(3), scheduler: MainScheduler.instance)
   .do(onNext: { $0.isDragAnimating = false })
   .do(onDispose : { self.dragStateSubscription = nil })
   .flatMap{ Observable.just($0)
                      .delay(.seconds(2), scheduler: MainScheduler.instance)
                      .do(onNext: {
                        $0.isSelected = false
                        $0.isDropProceeding = false
                        $0.isDragProceeding = false
                       })}
   .debug("<<< CLEAR DROPPED ITEM <\(self)> ID: [\(id?.uuidString ?? "NO ID")] >>>")
   .subscribe()
 }
 


 
}
