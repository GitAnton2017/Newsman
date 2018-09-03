

import Foundation
import UIKit

class TextPreviewProvider: SnippetPreviewImagesProvider
{
 func cancel()
 {
  
 }
 
 func cancelLocal()
 {
  
 }

 init(textSnippet: TextSnippet)
 {
  self.textSnippet = textSnippet
 }
 
 var textSnippet: TextSnippet
 
 func getLatestImage(requiredImageWidth: CGFloat, completion: @escaping (UIImage?) -> Void)
 {
  OperationQueue.main.addOperation{completion(UIImage(named: "text.main"))}
 }
 
 func getRandomImages(requiredImageWidth: CGFloat, completion: @escaping ([UIImage]?) -> Void)
 {
  
 }
 
 
}
