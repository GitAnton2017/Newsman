
import Foundation
import UIKit

extension SnippetsViewController: UITableViewDropDelegate
{
 func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator)
 {
  if let destIndexPath = coordinator.destinationIndexPath
  {
   switch editedSnippet
   {
    //case let sourcePhotoSnippet as TextSnippet: break
    
    case let sourcePhotoSnippet as PhotoSnippet:
     if let destPhotoSnippet = snippetsDataSource.snippetsData[destIndexPath.section][destIndexPath.row] as? PhotoSnippet
     {
       PhotoItem.movePhotos(from: sourcePhotoSnippet, to: destPhotoSnippet)
     }
    
    default: break
    
   }
    
   coordinator.items.forEach {coordinator.drop($0.dragItem, toRowAt: destIndexPath)}
   tableView.reloadRows(at: [destIndexPath], with: .fade)
    
   let sourceIndexPath = snippetIndexPath(snippet: editedSnippet)
   tableView.reloadRows(at: [sourceIndexPath], with: .none)
  }
 }
    
    
    
}
