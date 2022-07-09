
import Foundation
import UIKit

protocol SnippetPreviewImagesProvider: AnyObject
{
 func getLatestImage  (requiredImageWidth: CGFloat, completion: @escaping (UIImage?  ) -> Void)
 func getRandomImages (requiredImageWidth: CGFloat, completion: @escaping ([UIImage]?) -> Void)
 func cancelRandomImagesOperations()
 
}
