
import UIKit

protocol SnippetsBaseRepresentable where Self: UIViewController
{
 var currentSnippet: BaseSnippet                {get set}
}

protocol SnippetsRepresentable: SnippetsBaseRepresentable
{
 static var storyBoardID: String                {get    }
 var currentFRC: SnippetsFetchController?       {get set}
}
