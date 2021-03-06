
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
  
  guard let snippetCell = cell as? SnippetsViewCell else { return }
  snippetCell.stopImageProvider()
  
//  print ("didEndDisplaying - \(cell.isHidden)", indexPath, (snippetCell.hostedSnippet as! BaseSnippet).tag ?? "")

 }

 private func loadSnippetAnimatedImages(_ tableView: UITableView,
                                          for cell: SnippetsViewCell, at indexPath: IndexPath)
 {
 
  let groupType = self.groupType
  guard let provider = cell.hostedSnippet?.imageProvider  else {return}
  guard let snippet = cell.hostedSnippet else {return}
  if snippet[groupType] {return}

  let iconWidth = cell.snippetImage.frame.width
  
  provider.getLatestImage(requiredImageWidth: iconWidth)
  {[weak w_cell = cell, weak w_snippet = snippet] (image) in
 
   guard let wc = w_cell, let ws = w_snippet else {return}
   guard wc.hostedSnippet?.objectID == ws.objectID else {return}
   if ws[groupType] {return}
   
   DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(200))
   {[weak w_cell = cell, weak w_snippet = snippet] in
    
    guard let wc = w_cell, let ws = w_snippet else {return}
    guard wc.hostedSnippet?.objectID == ws.objectID else {return}
    if ws[groupType] {return}
    
    cell.imageSpinner.stopAnimating()
   
    UIView.transition(with: cell.snippetImage,
                      duration: 0.35,
                      options: [.transitionFlipFromTop, .curveEaseInOut],
                      animations: {cell.snippetImage.image = image},
                      completion:
                      {[weak w_cell = cell, weak w_snippet = snippet] _ in
                       
                       guard let wc = w_cell, let ws = w_snippet else {return}
                       guard wc.hostedSnippet?.objectID == ws.objectID  else {return}
                       if ws[groupType] {return}
                       
                       cell.snippetImage.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
                       UIView.animate(withDuration: 0.15,
                                      delay: 0.25,
                                      usingSpringWithDamping: 3500,
                                      initialSpringVelocity: 0,
                                      options: .curveEaseInOut,
                                      animations: {cell.snippetImage.transform = .identity},
                                      completion:
                                      { [weak w_cell = cell, weak w_snippet = snippet] _ in
                                       
                                       guard let wc = w_cell, let ws = w_snippet else {return}
                                       guard wc.hostedSnippet?.objectID == ws.objectID else {return}
                                       if ws[groupType] {return}
                                       
                                       provider.getRandomImages(requiredImageWidth: iconWidth)
                                       {[weak w_cell = cell, weak w_snippet = snippet] (images) in
                                        guard var images = images else {return}
                                        guard let wc = w_cell, let ws = w_snippet else {return}
                                        guard wc.hostedSnippet?.objectID == ws.objectID else {return}
                                        if ws[groupType] {return}
                                        
                                        if let firstImage = image {images.insert(firstImage, at: 0)}
                                        
                                        SnippetsAnimator.startRandom(for: Array(Set(images)),
                                                                     cell: wc,
                                                                     duration: 2.0, delay: 5.0)
                                      
           
                                       }//photoSnippet.imageProvider.getRandomImages {images in....
                                      } /* completion: { _ in.... */ )
                        } /* completion: { _ in.... */ )
   
   
   } //DispatchQueue.main.asyncAfter...
  } //photoSnippet.imageProvider.getLatestImage...
 }

 func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
 {
  
//  guard let cell = cell as? SnippetsViewCell else { return }
//  guard let snippet = cell.hostedSnippet as? BaseSnippet else {return}
//  
//
//  if snippet[groupType] {return}
//  loadSnippetAnimatedImages(tableView, for: cell, at: indexPath)

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

 
 final func persistSnippetsPriorityChange(for snippets: [BaseSnippet], to newPriority: SnippetPriority)
 {
  moc.persist
  {
   snippets.forEach
   {
    $0.snippetPriority = newPriority
    $0.isSelected = false
   }
  } as Void?
  
 }
 
 final func persistSnippetsSelection(for snippets: [BaseSnippet], to state: Bool)
 {
  moc.persist
  {
   snippets.forEach { $0.isSelected = state }
  } as Void?
 }
 
 
 
 final func persistSnippetsDeletion(for snippets: [BaseSnippet])
 {
  moc.persist
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
  } as Void?
  
 }
 
 final func persistSnippetNameChange(for snippet: BaseSnippet, to newName: String)
 {
  guard newName != snippet.snippetName else { return }
  moc.perform { snippet.snippetName = newName }
 }
 
 
 func changeSnippetsPriority(_ tableView: UITableView, _ indexPaths: [IndexPath], _ newPriority: SnippetPriority)
 {
   var snippets: [BaseSnippet] = []
   var deselects: [BaseSnippet] = []
  
   var snippetTags = ""
   var cnt = 1
  
   for indexPath in indexPaths
   {
    let snippet = snippetsDataSource[indexPath]
    
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
    else
    {
     deselects.append(snippet)
    }
   }
  
   persistSnippetsSelection(for: deselects, to: false)
  
   if snippets.count == 0 { return }
  
   let priorityAC = UIAlertController(title: Localized.changePriorityTitle,
                                      message: Localized.changePriorityConfirm + "\n\n" + snippetTags,
                                      preferredStyle: .alert)
  
   let changeAction = UIAlertAction(title: Localized.changeAction, style: .default)
   { _ in
    self.persistSnippetsPriorityChange(for: snippets, to: newPriority)
   }
  
   priorityAC.addAction(changeAction)
  
   let cancelAction = UIAlertAction(title: Localized.cancelAction, style: .cancel, handler: nil)
   priorityAC.addAction(cancelAction)
  
   self.presenter.present(priorityAC, animated: true, completion: nil)
  
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
      let snippet = snippetsDataSource[indexPath]
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
      self.persistSnippetsDeletion(for: snippets)
     }
  
     deleteAC.addAction(deleteAction)
  
     let cancelAction = UIAlertAction(title: Localized.cancelAction, style: .cancel, handler: nil)
     deleteAC.addAction(cancelAction)
  
     self.presenter.present(deleteAC, animated: true, completion: nil)
 }
 

 
 func tableView(_ tableView: UITableView,
                  trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
 {
  swipedSnippetIndexPath = indexPath
  let priority = UIContextualAction(style: .normal, title: Localized.priorityTag)
  {[unowned self] action, view, handler in
   let ac = SnippetPriority.caseSelectorController(title: self.snippetType.localizedString,
                                                   message: Localized.prioritySelect,
                                                   style: .alert)
   {
    self.changeSnippetsPriority(tableView, [indexPath], $0)
   }
   
   self.presenter.present(ac, animated: true, completion: nil)
   
   handler(true)
  }
  
  
  priority.backgroundColor = #colorLiteral(red: 0.09259795535, green: 0.0901308983, blue: 0.8686548223, alpha: 1)
  priority.image = UIImage(named: "priority.tab.icon")
  
  let delete = UIContextualAction(style: .normal, title: Localized.deleteTag)
  { [unowned self] action, view, handler in
   self.deleteSnippet(tableView, [indexPath])
   handler(true)
  }
  delete.backgroundColor = #colorLiteral(red: 0.905384423, green: 0.2660141546, blue: 0.007257829661, alpha: 1)
  delete.image = UIImage(named: "trash.snippet.trailing.menu")
  
  return UISwipeActionsConfiguration(actions: [priority, delete])
  
 }

 
 @objc func renameFieldChanged (_ sender: UITextField)
 {
  var resp: UIResponder! = sender
  while !(resp is UIAlertController) {resp = resp.next}
  (resp as! UIAlertController).actions.first{$0.title == Localized.changeAction}?.isEnabled = (sender.text != "")
  (snippetsTableView.cellForRow(at: swipedSnippetIndexPath!) as! SnippetsViewCell).snippetTextTag.text = sender.text
 }

 func tableView(_ tableView: UITableView,
                  leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
 {
  
  swipedSnippetIndexPath = indexPath
  let snippet = snippetsDataSource[indexPath]
  let rename = UIContextualAction(style: .normal, title: "Rename")
  {[unowned self] action, view, handler in
   let ac = UIAlertController(title: self.snippetType.localizedString, message: nil, preferredStyle: .alert)
   ac.addTextField
   {textField in
    textField.borderStyle = .none
    textField.font = UIFont.boldSystemFont(ofSize: 12)
    textField.textColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
    textField.addTarget(self, action: #selector(self.renameFieldChanged), for: .editingChanged)
    textField.clearButtonMode = .whileEditing
    textField.text = (snippet.snippetName == Localized.unnamedSnippet ? "" : snippet.snippetName)
    
   }
   
  
   let ok = UIAlertAction(title: Localized.changeAction, style: .destructive)
   {_ in
    guard let newName = ac.textFields?.first?.text else { return }
    self.persistSnippetNameChange(for: snippet, to: newName)
   }
   
   ok.isEnabled = false
   ac.addAction(ok)
   
   let cancel = UIAlertAction(title: Localized.cancelAction, style: .cancel, handler: nil)
   ac.addAction(cancel)
   
   tableView.selectRow(at: indexPath, animated: true, scrollPosition: .top)
   
   self.presenter.present(ac, animated: true, completion: nil)
  
   handler(true)
  }
  
  rename.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
  rename.image = UIImage(named: "rename.snippet.leading.menu")
  
  
  return UISwipeActionsConfiguration(actions: [rename])
 }

 
 func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
 {
  guard snippetsDataSource.searchString.isEmpty else { return nil }
  
  let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: SnippetsTableViewHeaderView.reuseID) as! SnippetsTableViewHeaderView
 
  header.title = snippetsDataSource.sectionTitle(for: section)
  header.titleColor = #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1)
  header.isHiddenSection = snippetsDataSource.isHiddenSection(section: section)
  
  
  return header
 }
 
 func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView?
 {
  let footer = tableView.dequeueReusableHeaderFooterView(withIdentifier: SnippetsTableViewFooterView.reuseID) as! SnippetsTableViewFooterView
  
  let NRows = snippetsDataSource.totalNumberOfRowsInSection(index: section)
  footer.title = Localized.totalSnippets + String(NRows)
  footer.titleColor = #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)
  return footer
 }
 
 
 func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
 {
  let rh = tableView.rowHeight
  let hiddenSection = snippetsDataSource.isHiddenSection(section: indexPath.section)
  let disclosedCell = snippetsDataSource.isDisclosedCell(for: indexPath)
  return hiddenSection ? 0 : (disclosedCell ? rh * 2 : rh)
 }
 
 
 
 func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
 {
  guard snippetsDataSource.searchString.isEmpty else { return 0 }
  let hiddenSection = snippetsDataSource.isHiddenSection(section: section)
  return hiddenSection ? 60.0 : 50.0
 }
 
 func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
 {
  return 40
 }
 
 func tableView(_ tableView: UITableView,
                  editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle
 {
  return .delete
 }

 

 func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath)
 {
  let deselectedSnippet = snippetsDataSource[indexPath]
  
  guard tableView.isEditing else { return }
  
  SnippetDragItem(snippet: deselectedSnippet).toggleSelection()
  
 }
 
 
 func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
 {
  let selectedSnippet = snippetsDataSource[indexPath]
  
  guard tableView.isEditing else
  {
   editSelectedSnippet(selectedSnippet: selectedSnippet)
   return
  }
  
  SnippetDragItem(snippet: selectedSnippet).toggleSelection()

 }
 
 func editSelectedSnippet(selectedSnippet: BaseSnippet)
 {
  switch selectedSnippet.snippetType
  {
   case .text:      editSnippet(with: TextSnippetViewController.self, snippetToEdit: selectedSnippet)
   case .video:     fallthrough
   case .photo:     editSnippet(with: PhotoSnippetViewController.self, snippetToEdit: selectedSnippet)
   case .audio:     break
   case .sketch:    break
   case .report:    break
   case .undefined: break
  }
 }

 func editSnippet <T> (with _ : T.Type, snippetToEdit: BaseSnippet) where T: SnippetsRepresentable
 {
  guard let vc = self.storyboard?.instantiateViewController(withIdentifier: T.storyBoardID) as? T else {return}
  
  editedSnippet = snippetToEdit
  vc.currentSnippet = snippetToEdit
  vc.currentFRC = self.snippetsDataSource.currentFRC
  
  
  (self.navigationController?.delegate as? NCTransitionsDelegate)?.currentSnippet = snippetToEdit
  
  vc.currentSnippet.snippetStatus = .old
  
  self.navigationController?.pushViewController(vc, animated: true)
 }

}
