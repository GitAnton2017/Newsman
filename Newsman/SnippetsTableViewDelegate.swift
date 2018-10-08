
import Foundation
import UIKit
import GameplayKit

extension SnippetsViewController: UITableViewDelegate
{
 func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath)
 {
  
  
  if !tableView.hasActiveDrag
  {
   if tableView.hasActiveDrop {return}
  }
  
  let snippetCell = cell as! SnippetsViewCell
  snippetCell.stopImageProvider()
  
//  print ("didEndDisplaying - \(cell.isHidden)", indexPath, (snippetCell.hostedSnippet as! BaseSnippet).tag ?? "")

 }

 private func loadSnippetAnimatedImages(_ tableView: UITableView, for cell: SnippetsViewCell, at indexPath: IndexPath)
 {
  
  let dataSource = tableView.dataSource as! SnippetsViewDataSource
//  let snippet = dataSource.snippetsData[indexPath.section][indexPath.row] as! SnippetImagesPreviewProvidable
  
  guard let snippet = cell.hostedSnippet else {return}
  
  let provider = snippet.imageProvider

  let iconWidth = cell.snippetImage.frame.width
 
  provider.getLatestImage(requiredImageWidth: iconWidth)
  {[weak wds = dataSource, weak wtv = tableView] (image) in
 
   guard let ds = wds, let tv = wtv else {return}
//   let ip = (ds.groupType == .byPriority) ? ds.snippetIndexPath(snippet: snippet as! BaseSnippet) : indexPath
   
   guard let ip = ds.currentFRC[snippet as! BaseSnippet],
         let cell = tv.cellForRow(at: ip) as? SnippetsViewCell else {return}
  
   guard let firstImage = image else
   {
    print ("NIL IMAGE", indexPath, (snippet as! BaseSnippet).tag ?? "")
    cell.imageSpinner.stopAnimating()
    return
   }
  
   DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1))
   {[weak wds = dataSource, weak wtv = tableView] in
    
    guard let ds = wds, let tv = wtv else {return}
//    let ip = (ds.groupType == .byPriority) ? ds.snippetIndexPath(snippet: snippet as! BaseSnippet) : indexPath
    
    guard let ip = ds.currentFRC[snippet as! BaseSnippet],
          let cell = tv.cellForRow(at: ip) as? SnippetsViewCell else {return}
    
    cell.imageSpinner.stopAnimating()
   
    UIView.transition(with: cell.snippetImage,
                      duration: 0.35,
                      options: [.transitionFlipFromTop, .curveEaseInOut],
                      animations: {cell.snippetImage.image = image},
                      completion:
                      {_ in
                       cell.snippetImage.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
                       UIView.animate(withDuration: 0.15,
                                      delay: 0.25,
                                      usingSpringWithDamping: 3500,
                                      initialSpringVelocity: 0,
                                      options: .curveEaseInOut,
                                      animations: {cell.snippetImage.transform = .identity},
                                      completion:
                                      { _ in
                                       provider.getRandomImages(requiredImageWidth: iconWidth)
                                       {[weak wds = dataSource, weak wtv = tableView] (images) in
                                        
                                        guard let ds = wds, let tv = wtv else {return}
                                        
//                                        let ip = (ds.groupType == .byPriority) ?
//                                         ds.snippetIndexPath(snippet: snippet as! BaseSnippet) : indexPath
        
                                        guard let ip = ds.currentFRC[snippet as! BaseSnippet],
                                              let cell = tv.cellForRow(at: ip) as? SnippetsViewCell else {return}
                                        
        
                                        cell.snippetImage.layer.removeAllAnimations()
                                        cell.animating = [:]
        
                                        guard var imgs = images else {return}
        
                                        imgs.insert(firstImage, at: 0)
                                        
                                        let max_b = ds.imagesAnimators.count - 1
                                        let a4rnd = GKRandomDistribution(lowestValue: 0, highestValue: max_b)
        
                                        ds.imagesAnimators[a4rnd.nextInt()](Array(Set(imgs)), cell, 2.0, 5.0)
           
                                       }//photoSnippet.imageProvider.getRandomImages {images in....
                                      } /* completion: { _ in.... */ )
                        } /* completion: { _ in.... */ )
   
   
   } //DispatchQueue.main.asyncAfter...
  } //photoSnippet.imageProvider.getLatestImage...
 }

 func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
 {
  
  let cell = cell as! SnippetsViewCell
  
//  print ("willDisplay", indexPath, (cell.hostedSnippet as! BaseSnippet).tag ?? "")
  
  loadSnippetAnimatedImages(tableView, for: cell, at: indexPath)
  
  let a4r = GKRandomDistribution(lowestValue: 2, highestValue: 3)
  let div = CGFloat(a4r.nextUniform())
  let dir = CGFloat(a4r.nextBool() ? 1 : -1)
  cell.transform = CGAffineTransform(translationX: -cell.bounds.width/div, y: dir * cell.bounds.height)
  UIView.animate(withDuration: 0.5,
                 delay: 0,
                 usingSpringWithDamping: 0.85,
                 initialSpringVelocity: 1.25,
                 options: .curveEaseInOut,
                 animations:
                 {
                  cell.transform = .identity
                 },
                 completion:
                 {_ in
                  cell.transform =  CGAffineTransform(rotationAngle: .pi / 80)
                  UIView.animate(withDuration: 0.25,
                                 delay: 0,
                                 usingSpringWithDamping: 0.045,
                                 initialSpringVelocity: 0.85,
                                 options: .curveEaseInOut,
                                 animations:
                                 {cell.transform = .identity},
                                 completion:
                                 {_ in
                    
                                  cell.transform =  CGAffineTransform (scaleX: 0.95, y: 0.75)
                    
                                  UIView.animate(withDuration: 0.25,
                                                 delay: 0,
                                                 usingSpringWithDamping: 1.25,
                                                 initialSpringVelocity: 0,
                                                 options: .curveEaseInOut,
                                                 animations: {cell.transform = .identity},
                                                 completion:
                                                 {_ in
                                                   let color = cell.backgroundColor
                                                   cell.backgroundColor = color?.withAlphaComponent(0.5)
                                                   UIView.animate(withDuration: 0.25){cell.backgroundColor = color}
                                                 })
                    
                                  })
                  
                 })
 }

 func changeSnippetPriority (_ tableView: UITableView, in sectionIndex: Int, snippet: BaseSnippet, newPriority: SnippetPriority)
 {
  let dataSource = (tableView.dataSource as! SnippetsViewDataSource)
  if let rowIndex = dataSource.snippetsData[sectionIndex].index(of: snippet)
  {
   let moved = dataSource.snippetsData[sectionIndex].remove(at: rowIndex)
   dataSource.snippetsData[newPriority.section].insert(moved, at: 0)
   let sourcePath = IndexPath(row: rowIndex, section: sectionIndex)
   let destinPath = IndexPath(row: 0, section: newPriority.section)
   tableView.moveRow(at: sourcePath, to: destinPath)
   let cell = tableView.cellForRow(at: destinPath)
   cell?.backgroundColor = newPriority.color
  }
 }
 //*************************************************************************************************
 func changeSnippetsPriority(_ tableView: UITableView, _ indexPaths: [IndexPath], _ newPriority: SnippetPriority)
 //*************************************************************************************************
 {
   var snippets: [BaseSnippet] = []
   var snippetTags = ""
   var cnt = 1
  
   for indexPath in indexPaths
   {
     let snippet = snippetsDataSource.currentFRC[indexPath]
     let oldPriority = snippet.priority
     if newPriority.rawValue != oldPriority
     {
      if let tag = snippet.tag, !tag.isEmpty
      {
       snippetTags.append("\"\(tag)\" from \"\(oldPriority!)\" to \"\(newPriority.rawValue)\"\(cnt == snippets.count ? "" : "\n")")
      }
      else
      {
       snippetTags.append("\"No tag\" from \"\(oldPriority!)\" to \"\(newPriority.rawValue)\"\(cnt == snippets.count ? "" : "\n")")
      }
      snippets.append(snippet)
      cnt += 1
     }
    
   }
  
   if snippets.count == 0 {return}
   let s = (snippets.count == 1 ? "" : "s")
   let s1 = (snippets.count == 1 ? snippets.first?.type: "Snippets")!
   let priorityAC = UIAlertController(title: "Change \(s1) priority!",
     message: "Are your sure\nyou want to change snippet\(s) priority:\n\n\(snippetTags)",
     preferredStyle: .alert)
  
   let changeAction = UIAlertAction(title: "CHANGE", style: .default)
   { _ in
//     if (dataSource.groupType == .byPriority)
//     {
//      for sectionIndex in 0..<dataSource.snippetsData.count
//      {
//       for x in snippets {self.changeSnippetPriority(tableView, in: sectionIndex, snippet: x, newPriority: newPriority)}
//      }
//     }
//     else
//     {
//      for sectionIndex in 0..<dataSource.snippetsData.count
//      {
//       for x in snippets
//       {
//        if let rowIndex = dataSource.snippetsData[sectionIndex].index(of: x)
//        {
//         let cell = tableView.cellForRow(at: IndexPath(row: rowIndex, section: sectionIndex))
//         cell?.backgroundColor = newPriority.color
//        }
//       }
//      }
//     }
    
     for x in snippets {x.priority = newPriority.rawValue}
    
     (UIApplication.shared.delegate as! AppDelegate).saveContext()
   }
  
   priorityAC.addAction(changeAction)
  
   let cancelAction = UIAlertAction(title: "CANCEL", style: .cancel, handler: nil)
   priorityAC.addAction(cancelAction)
  
   self.present(priorityAC, animated: true, completion: nil)
  
 }
 
 
 //*************************************************************************************************
 func deletePhotoSnippet(photoSnippet: PhotoSnippet)
 //*************************************************************************************************
 {
     if let photos = photoSnippet.photos
     {
         for photo in photos
         {
             let photoID = (photo as! Photo).id!.uuidString
             PhotoItem.imageCacheDict.forEach
             {
               $0.value.removeObject(forKey: photoID as NSString)
             }
         }
     }
  
     let docFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
     let snippetURL = docFolder.appendingPathComponent(photoSnippet.id!.uuidString)
     do
     {
       try FileManager.default.removeItem(at: snippetURL)
       print("PHOTO SNIPPET IMAGES DIRECTORY DELETED SUCCESSFULLY AT PATH:\n\(snippetURL.path)")
     }
     catch
     {
       print("ERROR DELETING PHOTO SNIPPET IMAGES DIRECTORY AT PATH:\n\(snippetURL.path)\n\(error.localizedDescription)")
     }
  
 }


 //*************************************************************************************************
 func deleteSnippet(_ tableView: UITableView, _ indexPaths: [IndexPath])
 //*************************************************************************************************
 {
     var snippets = [BaseSnippet]()
     var snippetTags = ""
     var cnt = 1
  
     for indexPath in indexPaths
     {
      
      let snippet = snippetsDataSource.currentFRC[indexPath]
      
      snippets.append(snippet)
      if let tag = snippet.tag, !tag.isEmpty
      {
       snippetTags.append("\"\(tag)\"\(cnt == indexPaths.count ? "" : "\n")")
      }
      else
      {
       snippetTags.append("\"No tag\"\(cnt == indexPaths.count ? "" : "\n")")
      }
      cnt += 1

     }
  
     let s = (snippets.count == 1 ? "" : "s")
     let s1 = (snippets.count == 1 ? snippets.first?.type: "Snippets")!
     let deleteAC = UIAlertController(title: "Delete \(s1)!",
         message: "Are your sure\nyou want to delete snippet\(s) with tag\(s)\n\n\(snippetTags)",
         preferredStyle: .alert)
  
     let deleteAction = UIAlertAction(title: "DELETE", style: .destructive)
     { _ in
         let appDelegate = UIApplication.shared.delegate as! AppDelegate
         let moc = appDelegate.persistentContainer.viewContext
      
         for snippet in snippets
         {
          let snippetIndex = self.snippetsDataSource.items.index(of: snippet)
          self.snippetsDataSource.items.remove(at: snippetIndex!)
          
          let deletedSnippetType = SnippetType(rawValue: snippet.type!)!
          switch (deletedSnippetType)
          {
           case .text:   break
           case .photo:  fallthrough
           case .video:  self.deletePhotoSnippet(photoSnippet: snippet as! PhotoSnippet)
           case .audio:  break
           case .sketch: break
           case .report: break
          }
          
          moc.delete(snippet)
          
         }
      
//         for sectionIndex in 0..<self.snippetsDataSource.snippetsData.count
//         {
//           for x in snippets
//           {
//             if let rowIndex = self.snippetsDataSource.snippetsData[sectionIndex].index(of: x)
//             {
//              self.snippetsDataSource.snippetsData[sectionIndex].remove(at: rowIndex)
//              tableView.deleteRows(at: [IndexPath(row: rowIndex, section: sectionIndex)], with: .fade)
//             }
//           }
//         }
      
   
         appDelegate.saveContext()
     }
     deleteAC.addAction(deleteAction)
  
     let cancelAction = UIAlertAction(title: "CANCEL", style: .cancel, handler: nil)
     deleteAC.addAction(cancelAction)
  
     self.present(deleteAC, animated: true, completion: nil)
 }
 //*************************************************************************************************
 func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?
 //*************************************************************************************************
 {
   let setPriorityAction = UITableViewRowAction(style: .normal, title: "Priority")
   {_,indexPath in
     let prioritySelect = UIAlertController(title: "\(self.snippetType.rawValue)",
         message: "Please select your snippet priority!",
         preferredStyle: .alert)
    
     for priority in SnippetPriority.priorities
     {
         let action = UIAlertAction(title: priority.rawValue, style: .default)
         { _ in
             self.changeSnippetsPriority(tableView, [indexPath], priority)
         }
         prioritySelect.addAction(action)
     }
    
     let cancelAction = UIAlertAction(title: "CANCEL", style: .cancel, handler: nil)
    
     prioritySelect.addAction(cancelAction)
    
     self.present(prioritySelect, animated: true, completion: nil)
   }
  
   setPriorityAction.backgroundColor = UIColor.brown

   let deleteAction = UITableViewRowAction(style: .normal, title: "Delete")
   {_,indexPath in
      self.deleteSnippet(tableView, [indexPath])
    
   }
   deleteAction.backgroundColor = UIColor.red
  
   return [setPriorityAction,deleteAction]
 }
 //*************************************************************************************************
 func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle
 //*************************************************************************************************
 {
  return .delete
 }
 //*************************************************************************************************
 func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
 //*************************************************************************************************
 {
     if tableView.isEditing {return}
  
     guard let type = snippetType else {return}

     switch type
     {
      case .text:    editTextSnippet(indexPath: indexPath)
      case .video:   fallthrough
      case .photo:   editPhotoSnippet(indexPath: indexPath)
      case .audio:   editAudioSnippet(indexPath: indexPath)
      case .sketch:  editSketchSnippet(indexPath: indexPath)
      case .report:  editReport(indexPath: indexPath)
      
     }
  
 }

 //*************************************************************************************************
 func editTextSnippet(indexPath: IndexPath)
 //*************************************************************************************************
 {
     guard let textSnippetVC = self.storyboard?.instantiateViewController(withIdentifier: "TextSnippetVC") as? TextSnippetViewController
     else
     {
         return
     }
  
     let textSnippet = snippetsDataSource.currentFRC[indexPath] as! TextSnippet
  
//     editedSnippet = snippetsDataSource.snippetsData[indexPath.section][indexPath.row]
  
     editedSnippet = textSnippet
     textSnippetVC.textSnippet = textSnippet
     (self.navigationController!.delegate as! NCTransitionsDelegate).currentSnippet = textSnippet
     textSnippetVC.textSnippet.status = SnippetStatus.old.rawValue
     self.navigationController?.pushViewController(textSnippetVC, animated: true)
  
 }
 //*************************************************************************************************
 func editPhotoSnippet(indexPath: IndexPath)
 //*************************************************************************************************
 {
     guard let photoSnippetVC = self.storyboard?.instantiateViewController(withIdentifier: "PhotoSnippetVC") as? PhotoSnippetViewController
         else
     {
        return
     }
  
//     editedSnippet = snippetsDataSource.snippetsData[indexPath.section][indexPath.row]
  
     let photoSnippet = snippetsDataSource.currentFRC[indexPath] as! PhotoSnippet
  
//     let photoSnippet = editedSnippet as! PhotoSnippet
  
     editedSnippet = photoSnippet
     photoSnippetVC.photoSnippet = photoSnippet
     photoSnippetVC.photoSnippetTableViewCell = snippetsTableView.cellForRow(at: indexPath) as? SnippetsViewCell
     (self.navigationController!.delegate as! NCTransitionsDelegate).currentSnippet = photoSnippet
     photoSnippetVC.photoSnippet.status = SnippetStatus.old.rawValue
     self.navigationController?.pushViewController(photoSnippetVC, animated: true)
  
     print("NAVIGATION STACK COUNT: \(navigationController!.viewControllers.count)")

 }
 //*************************************************************************************************
 func editVideoSnippet(indexPath: IndexPath)
 //*************************************************************************************************
 {
 }
 //*************************************************************************************************
 func editAudioSnippet(indexPath: IndexPath)
 //*************************************************************************************************
 {
 }
 //*************************************************************************************************
 func editSketchSnippet(indexPath: IndexPath)
 //*************************************************************************************************
 {
 }
 //*************************************************************************************************
 func editReport(indexPath: IndexPath)
 //*************************************************************************************************
 {
 }
 //*************************************************************************************************

}
