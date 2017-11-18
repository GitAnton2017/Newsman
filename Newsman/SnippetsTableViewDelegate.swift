
import Foundation
import UIKit

extension SnippetsViewController: UITableViewDelegate
{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
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
    
    func editTextSnippet(indexPath: IndexPath)
    {
        guard let textSnippetVC = self.storyboard?.instantiateViewController(withIdentifier: "TextSnippetVC") as? TextSnippetViewController
        else
        {
            return
        }
        textSnippetVC.modalTransitionStyle = .partialCurl
        textSnippetVC.textSnippet = snippetsDataSource.items[indexPath.row] as! TextSnippet
        self.navigationController?.pushViewController(textSnippetVC, animated: true)
    }
    
    func editPhotoSnippet(indexPath: IndexPath)
    {
    }
    
    func editVideoSnippet(indexPath: IndexPath)
    {
    }
    
    func editAudioSnippet(indexPath: IndexPath)
    {
    }
    
    func editSketchSnippet(indexPath: IndexPath)
    {
    }
    
    func editReport(indexPath: IndexPath)
    {
    }
    

}
