
import Foundation
import UIKit

protocol SnippetPreviewImagesProvider
{
 func getLatestImage  (requiredImageWidth: CGFloat, completion: @escaping (UIImage?  ) -> Void)
 func getRandomImages (requiredImageWidth: CGFloat, completion: @escaping ([UIImage]?) -> Void)
 func cancel()
 func cancelLocal()
}
