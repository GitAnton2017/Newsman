
import Foundation
import UIKit

protocol SnippetPreviewImagesProvider: class
{
 func getLatestImage  (requiredImageWidth: CGFloat, completion: @escaping (UIImage?  ) -> Void)
 func getRandomImages (requiredImageWidth: CGFloat, completion: @escaping ([UIImage]?) -> Void)
 func cancelRandomImagesOperations()
 
}
