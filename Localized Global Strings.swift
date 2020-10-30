
import Foundation

prefix operator §§

extension String
{
 var quoted: String {return "\"" + self + "\""}
 
 static prefix func §§ (s: String) -> String
 {
  return NSLocalizedString(s, comment: s)
 }
 
}


struct Localized
{
 
 
 static let fromPriority   = NSLocalizedString("From", comment: "From Priority")
 static let toPriority     = NSLocalizedString("To", comment: "To Priority")
 
 static let unnamedSnippet = §§"Unnamed Snippet"
 static let unnamedSection = §§"Unnamed Snippets"
 
 static let undefinedSnippetLocation = §§"Undefined Snippet Location"
 static let undefinedLocationSection = §§"Snippets with Undefined Location"
 
 static let prioritySelect = NSLocalizedString("Please select your snippet priority!",
                                               comment: "Priority Selection Alerts")
 
 static let groupingTitle  = NSLocalizedString("Group Snippets",
                                              comment: "Group Snippets Alerts Title")
 
 static let groupingSelect = NSLocalizedString("Please select grouping type",
                                               comment: "Group Snippets Alerts Message")
 
 static let cancelAction   = NSLocalizedString("CANCEL", comment: "Cancel Alert Action")
 static let changeAction   = NSLocalizedString("CHANGE", comment: "Change Alert Action")
 static let deleteAction   = NSLocalizedString("DELETE", comment: "Delete Alert Action")
 
 static let priorityTag   =  NSLocalizedString("Priority", comment: "Priority Action Tag")
 static let deleteTag   =    NSLocalizedString("Delete",   comment: "Delete Action Tag")
 
 static let changePriorityTitle = NSLocalizedString("Change Snippets Priority",
                                                    comment: "Change Snippets Priority Alert Action")
 
 static let changePriorityConfirm = NSLocalizedString("Are you sure you want to change the following snippets priorities?",
                                                      comment: "Change Snippets Priority Alert Confimation")
 
 static let deleteSnippetsTitle = NSLocalizedString("Deleting Snippets!",
                                                    comment: "Deletу Snippets Alert Action")
 
 static let deleteSnippestConfirm = NSLocalizedString("Are you sure you want to delete the following snippets?!",
                                                      comment: "Delete Snippets Alert Confimation")
 
 static let groupPhotoTitle =  NSLocalizedString("Group Photos", comment: "Group Photos Alerts Title")
 static let groupPhotoSelect = NSLocalizedString("Please select photo grouping type",
                                                 comment: "Group Photos Alerts Message")
 
 static let undoManagerTitle =  NSLocalizedString("Undo Manager", comment: "Undo Manager Alerts Title")
 static let undoManagerSelect = NSLocalizedString("Please select undo manager action",
                                                 comment: "Undo Manager Alerts Message")
 
 static let totalSnippets = NSLocalizedString("Total Snippets in this category: ",
                                              comment: "Total Snippets")
 
 static let plainList = NSLocalizedString("Plain List", comment: "Plain List")
 
 
 static let overallScope =  NSLocalizedString("Overall",   comment: "Overall")
 static let priorityScope = NSLocalizedString("Priorities",comment: "Priorities")
 static let nameScope =     NSLocalizedString("Names",     comment: "Names")
 static let dateScope =     NSLocalizedString("Dates",     comment: "Dates")
 static let contentScope =  NSLocalizedString("Texts",     comment: "Texts")
 static let LocationScope = NSLocalizedString("Locations", comment: "Locations")
 
 static let unflagged = §§"Not Flagged Yet"
 
 static let tagPhotoItem = §§"Search Tag"
 
  
}


