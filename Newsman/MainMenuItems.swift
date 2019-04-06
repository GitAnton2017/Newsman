
import Foundation
import UIKit

class MainMenuItems
{
    let title: String
    let mainIcon: UIImage
    let tabIcon: UIImage
    let tabTitle: String
    let type: SnippetType
    
    init (title: String, mainIcon : UIImage, tabIcon: UIImage, tabTitle: String, type: SnippetType)
    {
     self.title = title
     self.mainIcon = mainIcon
     self.tabIcon = tabIcon
     self.tabTitle = tabTitle
     self.type = type
    }
}
