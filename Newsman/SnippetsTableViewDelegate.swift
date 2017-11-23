
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
        let snippet = dataSource.spippetsData[path.section][path.row]
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
         for sectionIndex in 0..<dataSource.spippetsData.count
         {
          for x in snippets
          {
            if let rowIndex = dataSource.spippetsData[sectionIndex].index(of: x)
            {
             let moved = dataSource.spippetsData[sectionIndex].remove(at: rowIndex)
             dataSource.spippetsData[newPriority.section].insert(moved, at: 0)
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
         for sectionIndex in 0..<dataSource.spippetsData.count
         {
          for x in snippets
          {
           if let rowIndex = dataSource.spippetsData[sectionIndex].index(of: x)
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
    func deleteSnippet(_ tableView: UITableView, _ indexPaths: [IndexPath])
    //*************************************************************************************************
    {
        var snippets = [BaseSnippet]()
        var snippetTags = ""
        var cnt = 1
        for indexPath in indexPaths
        {
         let snippet = self.snippetsDataSource.spippetsData[indexPath.section][indexPath.row]
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
             moc.delete(snippet)
             let snippetIndex = self.snippetsDataSource.items.index(of: snippet)
             self.snippetsDataSource.items.remove(at: snippetIndex!)
             
            }
            
            for sectionIndex in 0..<self.snippetsDataSource.spippetsData.count
            {
              for x in snippets
              {
                if let rowIndex = self.snippetsDataSource.spippetsData[sectionIndex].index(of: x)
                {
                 self.snippetsDataSource.spippetsData[sectionIndex].remove(at: rowIndex)
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
        textSnippetVC.textSnippet = snippetsDataSource.spippetsData[indexPath.section][indexPath.row] as! TextSnippet
        self.navigationController?.pushViewController(textSnippetVC, animated: true)
        
        
        print (#function, textSnippetVC.textSnippet)
    }
    //*************************************************************************************************
    func editPhotoSnippet(indexPath: IndexPath)
    //*************************************************************************************************
    {
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
