
import Foundation
import UIKit

protocol ImageContextLoadProtocol
{
 var isLoadTaskCancelled: Bool {get set}
 var photoItems: [PhotoItem] {get set}
}

class SnippetsViewCell: UITableViewCell, CAAnimationDelegate, ImageContextLoadProtocol
{
 
    var photoItems: [PhotoItem] = []
 
    private var _stop_flag = false
 
    var snippetID: String
    {
     return (snippet as? BaseSnippet)?.id?.uuidString ?? ""
    }
 
    var snippet: SnippetImagesPreviewProvidable?
 
    var isLoadTaskCancelled: Bool
    {
     get
     {
      guard Thread.current != Thread.main else {return _stop_flag}
      return DispatchQueue.main.sync {return _stop_flag}
     }
     set
     {
      DispatchQueue.main.async {[weak self] in self?._stop_flag = newValue}
      //if newValue {photoItems.forEach{$0.cancelImageOperation()}
       //photoItems = []
      //}
     }
    }

 
    @IBOutlet var snippetTextTag: UILabel!
    @IBOutlet var snippetDateTag: UILabel!
    @IBOutlet var snippetImage: UIImageView!
    @IBOutlet var imageSpinner: UIActivityIndicatorView!
 
    var animate: ((TimeInterval) -> Void)?
    var transDuration = 0.0
    var animating: [String : Bool] = [:]
 
    override func awakeFromNib()
    {
     super.awakeFromNib()
     
     snippetImage.layer.cornerRadius = 3.5
     snippetImage.layer.borderWidth = 1.25
     snippetImage.layer.borderColor = UIColor(red: 236/255, green: 60/255, blue: 26/255, alpha: 1).cgColor
     snippetImage.layer.masksToBounds = true
     
    }
 
    func stopImageProvider()
    {
      if let snippet = self.snippet
      {
       snippet.imageProvider.cancel()
       self.snippet = nil
      }
    }
 
    func clear()
    {
     isLoadTaskCancelled = false
     snippetImage.layer.removeAllAnimations()
     animate = nil
     animating = [:]
     transDuration = 0.0
     imageSpinner.startAnimating()
     snippetImage.image = nil

    }
 
    override func prepareForReuse()
    {
     super.prepareForReuse()
     clear()
   
    }
 
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool)
    {
     guard let status = animating["trans2" + snippetID], status else {return}
     let id = self.snippetID
     if (flag)
     {
      DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + transDuration * 0.75)
      {[weak self] in
       guard let cell = self, cell.snippetID == id else {return}
       guard let status = cell.animating["trans2" + cell.snippetID], status else {return}
       cell.animate?(0.25 * cell.transDuration)
     
      }
     }
    }
 
    deinit
    {
     print ("Snippet cell with ID\(snippetID) DESTROYED!")
    }
}

