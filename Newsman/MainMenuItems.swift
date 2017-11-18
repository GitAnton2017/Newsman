
import Foundation
import UIKit

class MainMenuItems
{
    let title: String
    let mainIcon: UIImage
    let tabIcon: UIImage
    let type: SnippetType
    
    init (title: String, mainIcon : UIImage, tabIcon: UIImage, type: SnippetType)
    {
     self.title = title
     self.mainIcon = mainIcon
     self.tabIcon = tabIcon
     self.type = type
    }
}
