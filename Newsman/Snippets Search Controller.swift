//
//  Snippets Search Controller.swift
//  Newsman
//
//  Created by Anton2016 on 01/03/2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import UIKit

extension SnippetsViewController: UISearchResultsUpdating, UISearchBarDelegate, UISearchControllerDelegate
{
 func updateSearchResults(for searchController: UISearchController)
 {
  guard let searchString = searchController.searchBar.text else { return }
  snippetsDataSource.searchString = searchString
 }
 
 
 func configueSearchController()
 {
  let searchController = UISearchController(searchResultsController: nil)
  searchController.obscuresBackgroundDuringPresentation = false
  searchController.definesPresentationContext = true
  self.definesPresentationContext = true
  searchController.hidesNavigationBarDuringPresentation = false
  
  searchController.searchResultsUpdater = self
  searchController.searchBar.delegate = self
  searchController.delegate = self
  
  navigationItem.searchController = searchController
  searchController.searchBar.scopeButtonTitles = snippetType?.localizedSearchScopeBarTitles
  searchController.searchBar.showsScopeBar = true
  searchController.searchBar.sizeToFit()
  searchController.searchBar.tintColor = UIColor.white
  
  

 }
 
 var presenter: UIViewController
 {
  var presenter: UIViewController = self
  while let next = presenter.presentedViewController { presenter = next }
  return presenter
 }
 
 func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int)
 {
  snippetsDataSource.searchScopeIndex = selectedScope
  Defaults.setSearchScopeIndex(index: selectedScope, for: snippetType)
 }
 
 func searchBarTextDidBeginEditing(_ searchBar: UISearchBar)
 {
  guard searchBar.scopeButtonTitles == nil else { return }
  searchBar.scopeButtonTitles = snippetType?.localizedSearchScopeBarTitles
 }
 
// func willPresentSearchController(_ searchController: UISearchController)
// {
//  guard searchController.searchBar.scopeButtonTitles == nil else { return }
//  searchController.searchBar.scopeButtonTitles = snippetType?.localizedSearchScopeBarTitles
// }
 
}
