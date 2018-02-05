
import Foundation
import UIKit

extension SnippetsViewController: UITableViewDropDelegate
{
 func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator)
 {
  let sourceIndexPath = snippetIndexPath(snippet: editedSnippet)
  if let destIndexPath = coordinator.destinationIndexPath
  {
   switch editedSnippet
   {
    //case let sourcePhotoSnippet as TextSnippet: break
    
    case let sourcePhotoSnippet as PhotoSnippet:
     if let destPhotoSnippet = snippetsDataSource.snippetsData[destIndexPath.section][destIndexPath.row] as? PhotoSnippet,
        sourceIndexPath != destIndexPath
     {
       PhotoItem.movePhotos(from: sourcePhotoSnippet, to: destPhotoSnippet)
       coordinator.session.localDragSession?.localContext = nil
       editPhotoSnippet(indexPath: destIndexPath)
     }
     else
     {
       PhotoItem.deselectPhotos(at: sourcePhotoSnippet)
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
    
    
    
}
