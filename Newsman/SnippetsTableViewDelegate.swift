
import Foundation
import UIKit

extension SnippetsViewController: UITableViewDelegate
{
    
    //*************************************************************************************************
    func changeSnippetPriority(_ tableView: UITableView, _ indexPath: IndexPath, _ newPriority: SnippetPriority)
    //*************************************************************************************************
    {
      let snippet = snippetsDataSource.spippetsData[indexPath.section][indexPath.row]
      let oldPriority = snippet.priority
      if (newPriority.rawValue == oldPriority || snippetsDataSource.groupType != .byPriority)
      {
        return
      }
        
      let cell = tableView.cellForRow(at: indexPath)
      cell?.backgroundColor = newPriority.color
      snippet.priority = newPriority.rawValue
      snippetsDataSource.rebuildData()
      tableView.reloadData()
      (UIApplication.shared.delegate as! AppDelegate).saveContext()
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
        
        let hottest = UIAlertAction(title: SnippetPriority.hottest.rawValue, style: .default)
        { _ in
            self.changeSnippetPriority(tableView, indexPath, .hottest)
            
        }
        prioritySelect.addAction(hottest)
        
        let hot = UIAlertAction(title: SnippetPriority.hot.rawValue, style: .default)
        { _ in
            self.changeSnippetPriority(tableView, indexPath, .hot)
        }
        prioritySelect.addAction(hot)
        
        let high = UIAlertAction(title: SnippetPriority.high.rawValue, style: .default)
        { _ in
            self.changeSnippetPriority(tableView, indexPath, .high)
        }
        prioritySelect.addAction(high)
        
        let normal = UIAlertAction(title: SnippetPriority.normal.rawValue, style: .default)
        { _ in
            self.changeSnippetPriority(tableView, indexPath,.normal)
        }
        prioritySelect.addAction(normal)
        
        let medium = UIAlertAction(title: SnippetPriority.medium.rawValue, style: .default)
        { _ in
            self.changeSnippetPriority(tableView, indexPath, .medium)
        }
        prioritySelect.addAction(medium)
        
        let low = UIAlertAction(title: SnippetPriority.low.rawValue, style: .default)
        { _ in
            self.changeSnippetPriority(tableView, indexPath, .low)
        }
        prioritySelect.addAction(low)
        
        let cancelAction = UIAlertAction(title: "CANCEL", style: .cancel, handler: nil)
        
        prioritySelect.addAction(cancelAction)
        
        self.present(prioritySelect, animated: true, completion: nil)
      }
      setPriorityAction.backgroundColor = UIColor.brown
    
      let deleteAction = UITableViewRowAction(style: .normal, title: "Delete")
      {_,indexPath in
        let snippet = self.snippetsDataSource.spippetsData[indexPath.section][indexPath.row]
        let deleteAC = UIAlertController(title: "\(self.snippetType.rawValue)",
            message: "Are your sure you want to delete snippet with tag \n\"\(snippet.tag ?? "No tag")\"",
            preferredStyle: .alert)
        
        let deleteAction = UIAlertAction(title: "DELETE", style: .destructive)
        { _ in
          let appDelegate = UIApplication.shared.delegate as! AppDelegate
          let moc = appDelegate.persistentContainer.viewContext
          moc.delete(snippet)
          let snippetIndex = self.snippetsDataSource.items.index(of: snippet)
          self.snippetsDataSource.items.remove(at: snippetIndex!)
          self.snippetsDataSource.spippetsData[indexPath.section].remove(at: indexPath.row)
          tableView.deleteRows(at: [indexPath], with: .fade)
          appDelegate.saveContext()
        }
        deleteAC.addAction(deleteAction)
        
        let cancelAction = UIAlertAction(title: "CANCEL", style: .cancel, handler: nil)
        
        deleteAC.addAction(cancelAction)
        
        self.present(deleteAC, animated: true, completion: nil)
        
      }
      deleteAction.backgroundColor = UIColor.red
        
      return [setPriorityAction, deleteAction]
    }
    //*************************************************************************************************
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    //*************************************************************************************************
    {
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
