
import Foundation

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
 
 static let changePriorityTitle = NSLocalizedString("Change Snippets Priority", comment: "Change Snippets Priority Alert Action")
 
 static let changePriorityConfirm = NSLocalizedString("Are you sure you want to change the following snippets priorities?", comment: "Change Snippets Priority Alert Confimation")
 
 

}


extension String
{
 var quoted: String {return "\"" + self + "\""}
}


protocol StringLocalizable
{
 var localizedString: String {get}
}
