
import Foundation
import UIKit

extension SnippetsViewController: UITableViewDelegate
{
    
    //*************************************************************************************************
    func changeSnippetPriority(_ tableView: UITableView, _ indexPaths: [IndexPath], _ newPriority: SnippetPriority)
    //*************************************************************************************************
    {
      var snippets: [BaseSnippet] = []
      var snippetTags = ""
      var cnt = 1
      let dataSource = (tableView.dataSource as! SnippetsViewDataSource)
        
      for path in indexPaths
      {
        let snippet = dataSource.snippetsData[path.section][path.row]
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
        if (dataSource.groupType == .byPriority)
        {
         for sectionIndex in 0..<dataSource.snippetsData.count
         {
          for x in snippets
          {
            if let rowIndex = dataSource.snippetsData[sectionIndex].index(of: x)
            {
             let moved = dataSource.snippetsData[sectionIndex].remove(at: rowIndex)
             dataSource.snippetsData[newPriority.section].insert(moved, at: 0)
             let sourcePath = IndexPath(row: rowIndex, section: sectionIndex)
             let destinPath = IndexPath(row:        0, section: newPriority.section)
             tableView.moveRow(at: sourcePath, to: destinPath)
             let cell = tableView.cellForRow(at: destinPath)
             cell?.backgroundColor = newPriority.color
            }
           }
         }
        }
        else
        {
         for sectionIndex in 0..<dataSource.snippetsData.count
         {
          for x in snippets
          {
           if let rowIndex = dataSource.snippetsData[sectionIndex].index(of: x)
           {
            let cell = tableView.cellForRow(at: IndexPath(row: rowIndex, section: sectionIndex))
            cell?.backgroundColor = newPriority.color
           }
          }
         }
        }
        
        for x in snippets {x.priority = newPriority.rawValue}
        
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
      }
      
      priorityAC.addAction(changeAction)
        
      let cancelAction = UIAlertAction(title: "CANCEL", style: .cancel, handler: nil)
      priorityAC.addAction(cancelAction)
        
      self.present(priorityAC, animated: true, completion: nil)
        
      /*let cell = tableView.cellForRow(at: indexPath)
      cell?.backgroundColor = newPriority.color
      snippet.priority = newPriority.rawValue
      snippetsDataSource.rebuildData()
      tableView.reloadData()
      (UIApplication.shared.delegate as! AppDelegate).saveContext()*/
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
                for item in PhotoItem.imageCacheDict
                {
                  item.value.removeObject(forKey: photoID as NSString)
                }
            }
        }
        let docFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let snippetURL = docFolder.appendingPathComponent(photoSnippet.id!.uuidString)
        do
        {
            try FileManager.default.removeItem(at: snippetURL)
            print("IMAGE FOLDER DELETED SUCCESSFULLY AT PATH:\n\(snippetURL.path)")
        }
        catch
        {
            print("ERROR DELETING IMAGE FOLDER AT PATH:\n\(snippetURL.path)\n\(error.localizedDescription)")
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
         let snippet = self.snippetsDataSource.snippetsData[indexPath.section][indexPath.row]
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
              case .photo:
                self.deletePhotoSnippet(photoSnippet: snippet as! PhotoSnippet)
                
              case .video:  break
              case .audio:  break
              case .sketch: break
              case .report: break
             }
                
             moc.delete(snippet)
                
            }
            
            for sectionIndex in 0..<self.snippetsDataSource.snippetsData.count
            {
              for x in snippets
              {
                if let rowIndex = self.snippetsDataSource.snippetsData[sectionIndex].index(of: x)
                {
                 self.snippetsDataSource.snippetsData[sectionIndex].remove(at: rowIndex)
                 tableView.deleteRows(at: [IndexPath(row: rowIndex, section: sectionIndex)], with: .fade)
                }
              }
            }
            
            /*for indexPath in indexPaths
            {
              self.snippetsDataSource.spippetsData[indexPath.section].remove(at: indexPath.row)
            }*/

            
            
            
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
                self.changeSnippetPriority(tableView, [indexPath], priority)
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
    
        switch (snippetType)
        {
         case .text:    editTextSnippet(indexPath: indexPath)
         case .photo:   editPhotoSnippet(indexPath: indexPath)
         case .video:   editVideoSnippet(indexPath: indexPath)
         case .audio:   editAudioSnippet(indexPath: indexPath)
         case .sketch:  editSketchSnippet(indexPath: indexPath)
         case .report:  editReport(indexPath: indexPath)
         default: break
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
        textSnippetVC.modalTransitionStyle = .partialCurl
        editedSnippet = snippetsDataSource.snippetsData[indexPath.section][indexPath.row]
        textSnippetVC.textSnippet = editedSnippet as! TextSnippet
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
        photoSnippetVC.modalTransitionStyle = .partialCurl
        editedSnippet = snippetsDataSource.snippetsData[indexPath.section][indexPath.row]
        let photoSnippet = editedSnippet as! PhotoSnippet
        photoSnippetVC.photoSnippet = photoSnippet
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
