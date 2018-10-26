
import Foundation
import UIKit
import GameplayKit

extension SnippetsViewController: UITableViewDelegate
{
 func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath)
 {

  if let vr = tableView.indexPathsForVisibleRows, vr.contains(indexPath) {return}
  
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
    print ("NIL IMAGE", indexPath, (snippet as! BaseSnippet).snippetName)
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

 
 func changeSnippetsPriority(_ tableView: UITableView, _ indexPaths: [IndexPath], _ newPriority: SnippetPriority)
 {
   var snippets: [BaseSnippet] = [];  var snippetTags = "";  var cnt = 1
  
   for indexPath in indexPaths
   {
    let snippet = snippetsDataSource.currentFRC[indexPath]
   
    let oldPriority = snippet.snippetPriority

    if (newPriority != oldPriority)
    {
     let name = NSLocalizedString(snippet.snippetName, comment: snippet.snippetName)
     let tag = name.quoted + " " + Localized.fromPriority + " " + oldPriority.localizedString.quoted +
                             " " + Localized.toPriority   + " " + newPriority.localizedString.quoted
                                 + (cnt == snippets.count ? "" : "\n")
     snippetTags.append(tag)
     snippets.append(snippet)
     cnt += 1
    }
   }
  
   if snippets.count == 0 {return}
   let priorityAC = UIAlertController(title: Localized.changePriorityTitle,
                                      message: Localized.changePriorityConfirm + "\n\n" + snippetTags,
                                      preferredStyle: .alert)
  
   let changeAction = UIAlertAction(title: Localized.changeAction, style: .default)
   { _ in
    self.moc.persistAndWait {snippets.forEach{$0.snippetPriority = newPriority}}
   }
  
   priorityAC.addAction(changeAction)
  
   let cancelAction = UIAlertAction(title: Localized.cancelAction, style: .cancel, handler: nil)
   priorityAC.addAction(cancelAction)
  
   self.present(priorityAC, animated: true, completion: nil)
  
 }
 
 func deletePhotoSnippet(photoSnippet: PhotoSnippet)
 {
  if let photos = photoSnippet.photos
  {
   for photo in photos
   {
    let photoID = (photo as! Photo).id!.uuidString
    PhotoItem.imageCacheDict.forEach {$0.value.removeObject(forKey: photoID as NSString)}
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

 func deleteSnippet(_ tableView: UITableView, _ indexPaths: [IndexPath])
 {
     var snippets = [BaseSnippet](); var snippetTags = "";   var cnt = 1
  
     for indexPath in indexPaths
     {
      let snippet = snippetsDataSource.currentFRC[indexPath]
      let name = NSLocalizedString(snippet.snippetName, comment: snippet.snippetName)
      let tag = name.quoted + (cnt == snippets.count ? "" : "\n")
      snippetTags.append(tag)
      snippets.append(snippet)
      cnt += 1
     }
  
  
     let deleteAC = UIAlertController(title: Localized.deleteSnippetsTitle,
                                      message: Localized.deleteSnippestConfirm + "\n\n" + snippetTags,
                                      preferredStyle: .alert)
  
     let deleteAction = UIAlertAction(title: Localized.deleteAction, style: .destructive)
     { _ in
       self.moc.persistAndWait
       {
         for snippet in snippets
         {
          switch snippet.snippetType
          {
           case .text:   break
           case .photo:  fallthrough
           case .video:  self.deletePhotoSnippet(photoSnippet: snippet as! PhotoSnippet)
           case .audio:  break
           case .sketch: break
           case .report: break
           case .undefined: break
          }
          
          self.moc.delete(snippet)
          
         }
      }
      
   
     }
     deleteAC.addAction(deleteAction)
  
     let cancelAction = UIAlertAction(title: Localized.cancelAction, style: .cancel, handler: nil)
     deleteAC.addAction(cancelAction)
  
     self.present(deleteAC, animated: true, completion: nil)
 }
 
 
 func tableView(_ tableView: UITableView,
                  trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
 {
  let priority = UIContextualAction(style: .normal, title: Localized.priorityTag)
  {action, view, handler in
   let ac = SnippetPriority.caseSelectorController(title: self.snippetType.localizedString,
                                                   message: Localized.prioritySelect,
                                                   style: .alert) {self.changeSnippetsPriority(tableView, [indexPath], $0)}
   
   self.present(ac, animated: true, completion: nil)
   handler(true)
  }
  
  
  priority.backgroundColor = #colorLiteral(red: 0.09259795535, green: 0.0901308983, blue: 0.8686548223, alpha: 1)
  priority.image = UIImage(named: "flag.menu.icon")
  
  let delete = UIContextualAction(style: .normal, title: Localized.deleteTag)
  { action, view, handler in
   self.deleteSnippet(tableView, [indexPath])
   handler(true)
  }
  delete.backgroundColor = #colorLiteral(red: 0.905384423, green: 0.2660141546, blue: 0.007257829661, alpha: 1)
  delete.image = UIImage(named: "trash.menu.icon")
  
  return UISwipeActionsConfiguration(actions: [priority, delete])
  
 }

 func tableView(_ tableView: UITableView,
                  leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
 {
  let snippet = snippetsDataSource.currentFRC[indexPath]
  let rename = UIContextualAction(style: .normal, title: "RENAME")
  {action, view, handler in
   let ac = UIAlertController(title: self.snippetType.localizedString, message: nil, preferredStyle: .alert)
   ac.addTextField
   {textField in
    textField.text = (snippet.snippetName == Localized.unnamedSnippet ? "" : snippet.snippetName)
   }
   
   let ok = UIAlertAction(title: "OK", style: .destructive)
   {_ in
    guard let newName = ac.textFields?.first?.text, newName != snippet.snippetName else {return}
    self.moc.persist {snippet.snippetName = newName}
   }
   
   ac.addAction(ok)
   
   let cancel = UIAlertAction(title: Localized.cancelAction, style: .cancel, handler: nil)
   ac.addAction(cancel)
   
   self.present(ac, animated: true, completion: nil)
   handler(true)
  }
  
  rename.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
  
  return UISwipeActionsConfiguration(actions: [rename])
 }
 
 func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle
 {
  return .delete
 }

 func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
 {
  if tableView.isEditing {return}

  guard let type = snippetType else {return}

  let selectedSnippet = snippetsDataSource.currentFRC[indexPath]

  switch type
  {
   case .text:      editTextSnippet(snippetToEdit: selectedSnippet as! TextSnippet)
   case .video:     fallthrough
   case .photo:     editVisualSnippet(snippetToEdit: selectedSnippet as! PhotoSnippet)
   case .audio:     break
   case .sketch:    break
   case .report:    break
   case .undefined: break
  }
 }

 
 func editTextSnippet(snippetToEdit: TextSnippet)
 {
  guard let textSnippetVC = self.storyboard?.instantiateViewController(withIdentifier: "TextSnippetVC") as? TextSnippetViewController else {return}

  editedSnippet = snippetToEdit

  textSnippetVC.textSnippet = snippetToEdit
  (self.navigationController?.delegate as? NCTransitionsDelegate)?.currentSnippet = snippetToEdit
  textSnippetVC.textSnippet.snippetStatus = .old
  self.navigationController?.pushViewController(textSnippetVC, animated: true)
  
 }
 
 
 
 func editVisualSnippet(snippetToEdit: PhotoSnippet)
 {
  guard let photoSnippetVC = self.storyboard?.instantiateViewController(withIdentifier: "PhotoSnippetVC") as? PhotoSnippetViewController else {return}

  editedSnippet = snippetToEdit

  photoSnippetVC.photoSnippet = snippetToEdit
  (self.navigationController?.delegate as? NCTransitionsDelegate)?.currentSnippet = snippetToEdit
  photoSnippetVC.photoSnippet.snippetStatus = .old
  self.navigationController?.pushViewController(photoSnippetVC, animated: true)

 }

}
