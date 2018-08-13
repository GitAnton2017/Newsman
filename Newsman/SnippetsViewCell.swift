
import Foundation
import UIKit



protocol ImageContextLoadProtocol
{
 var isLoadTaskCancelled: Bool {get set}
 func stopAllContextTasks()
}

class SnippetsViewCell: UITableViewCell, CAAnimationDelegate, ImageContextLoadProtocol
{
 
    static let isq = DispatchQueue.global(qos: .userInitiated)
    private var _stop_flag = false
    var snippetID: String = ""
 
    var isLoadTaskCancelled: Bool
    {
     get
     {
      guard Thread.current != Thread.main else {return _stop_flag}
      return DispatchQueue.main.sync {return _stop_flag}
     }
     set {DispatchQueue.main.async {[weak self] in self?._stop_flag = newValue}}
    }
 
    func stopAllContextTasks()
    {
     isLoadTaskCancelled = true
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
 
    func clear()
    {
     isLoadTaskCancelled = false
     snippetImage.layer.removeAllAnimations()
     animate = nil
     animating = [:]
     transDuration = 0.0
     imageSpinner.startAnimating()
     snippetImage.image = nil
     snippetID = ""
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
       guard self?.snippetID == id else {return}
       guard let status = self?.animating["trans2" + (self?.snippetID ?? "")], status else {return}
       self?.animate?(0.25 * (self?.transDuration ?? 0.0))
     
      }
     }
    }
}

