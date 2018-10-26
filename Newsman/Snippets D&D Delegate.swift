
import Foundation
import UIKit

extension SnippetsViewController: UITableViewDropDelegate, UITableViewDragDelegate
{
 func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem]
 {
   //TO DO....
  return []
 }
 
 
 func tableView(_ tableView: UITableView, dropSessionDidEnd session: UIDropSession)
 {
  //snippetsDataSource.currentFRC.removeEmptySections()
 }
 
 func tableView(_ tableView: UITableView, dragSessionDidEnd session: UIDragSession)
 {
  //TO DO....
 }

 
 func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator)
 {
  guard let destIndexPath = coordinator.destinationIndexPath else {return}
  guard let editedSnippet = self.editedSnippet else {return}
  guard let sourceIndexPath = snippetsDataSource.currentFRC[editedSnippet] else {return}
  
  switch editedSnippet
  {
   //case let sourcePhotoSnippet as TextSnippet: break
   
   case let sourcePhotoSnippet as PhotoSnippet:
    if let destPhotoSnippet = snippetsDataSource.currentFRC[destIndexPath] as? PhotoSnippet,
     sourceIndexPath != destIndexPath
    {
     PhotoItem.movePhotos(from: sourcePhotoSnippet, to: destPhotoSnippet)
     PhotoItem.moveFolders(from: sourcePhotoSnippet, to: destPhotoSnippet)
     coordinator.session.localDragSession?.localContext = nil
     PhotoItem.deselectSelectedItems(at: destPhotoSnippet)
     editVisualSnippet(snippetToEdit: destPhotoSnippet)
    }
    else
    {
     PhotoItem.deselectSelectedItems(at: sourcePhotoSnippet)
     if let vc = coordinator.session.localDragSession?.localContext as? PhotoSnippetViewController
     {
      navigationController?.pushViewController(vc, animated: true)
     }
    }
   
   default: break
   
  }
  

  coordinator.items.forEach {coordinator.drop($0.dragItem, toRowAt: destIndexPath)}
  tableView.reloadRows(at: [destIndexPath], with: .fade)
  tableView.reloadRows(at: [sourceIndexPath], with: .none)
 }
    
    
    
}
