
import Foundation

extension String
{
 var quoted: String {return "\"" + self + "\""}
}

protocol StringLocalizable
{
 var localizedString: String {get}
}

struct Localized
{
 static let fromPriority   = NSLocalizedString("From", comment: "From Priority")
 static let toPriority     = NSLocalizedString("To", comment: "To Priority")
 static let unnamedSnippet = NSLocalizedString("Unnamed Snippet", comment: "Unnamed Snippet")
 static let unnamedSection = NSLocalizedString("Unnamed Snippets", comment: "Unnamed Snippets")
 static let prioritySelect = NSLocalizedString("Please select your snippet priority!", comment: "Priority Selection Alerts")
 
 static let groupingTitle  = NSLocalizedString("Group Snippets", comment: "Group Snippets Alerts Title")
 static let groupingSelect = NSLocalizedString("Please select grouping type", comment: "Group Snippets Alerts Message")
 
 static let cancelAction   = NSLocalizedString("CANCEL", comment: "Cancel Alert Action")
 static let changeAction   = NSLocalizedString("CHANGE", comment: "Change Alert Action")
 static let deleteAction   = NSLocalizedString("DELETE", comment: "Delete Alert Action")
 
 static let priorityTag   =  NSLocalizedString("Priority", comment: "Priority Action Tag")
 static let deleteTag   =    NSLocalizedString("Delete",   comment: "Delete Action Tag")
 
 static let changePriorityTitle = NSLocalizedString("Change Snippets Priority", comment: "Change Snippets Priority Alert Action")
 
 static let changePriorityConfirm = NSLocalizedString("Are you sure you want to change the following snippets priorities?", comment: "Change Snippets Priority Alert Confimation")
 
 static let deleteSnippetsTitle = NSLocalizedString("Deleting Snippets!", comment: "Deletу Snippets Alert Action")
 
 static let deleteSnippestConfirm = NSLocalizedString("Are you sure you want to delete the following snippets?!", comment: "Delete Snippets Alert Confimation")
 
 static let groupPhotoTitle =  NSLocalizedString("Group Photos", comment: "Group Photos Alerts Title")
 static let groupPhotoSelect = NSLocalizedString("Please select photo grouping type", comment: "Group Photos Alerts Message")
 
 static let totalSnippets = NSLocalizedString("Total Snippets in this category: ", comment: "Total Snippets")
 
}


