
import Foundation
import UIKit

class PlaybackButton: UIButton, PhotoSnippetCellProtocol
{
 var photoItemView: UIView {return self}
 var cellFrame: CGRect {return self.frame}
 var isPhotoItemSelected: Bool = false

}
