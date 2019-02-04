//
//  SearchController.swift
//  Vocabulary
//
//  Created by Alex on 26.06.17.
//  Copyright © 2017 Azurcoding. All rights reserved.
//

import UIKit
import RealmSwift


class SearchController : StyleableTableViewController{
    
    var languages: List<Language>?
    var language : Language?
    var collection: Collection?
    var collections: List<Collection>?
    
    var allWords : Results<Word>!
    var filteredWords : Results<Word>!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.title = "All Words"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "Cancel".localized(), style: .done, target: self, action: #selector(cancel))
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true //stellt sicher, dass searchBar nur in dieser view angezeigt wird
        tableView.tableHeaderView = searchController.searchBar //add search bar
        searchController.hidesNavigationBarDuringPresentation = false
        
        //get all of the users words from the Realm database
        allWords = RealmHelper.sharedInstance.realm.objects(Word.self)
        
        self.viewSetup()
        
    }
    
    func cancel(){
        
        searchController.isActive = false
        self.dismiss(animated: true, completion: nil)
        
    }
    
    override func viewSetup() {
        
        tableView.rowHeight = 60
        tableView.backgroundColor = .white
        tableView.showsVerticalScrollIndicator = false;
        tableView.emptyDataSetDataSource = self
        tableView.emptyDataSetDelegate = self
        tableView.register(Cell.self, forCellReuseIdentifier: "Cell")
        
    }
    
    
    func updateSearchResults(for searchController: UISearchController) {
        
        if let searchText = searchController.searchBar.text, !searchText.isEmpty {
            filteredWords = RealmHelper.sharedInstance.realm.objects(Word.self).filter("name CONTAINS[cd] %@ OR translation CONTAINS[cd] %@", searchText, searchText)
            }
        
        tableView.reloadData()

    }
    
   
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        if (searchController.isActive && searchController.searchBar.text != "") {
            return filteredWords.count
        }
        return RealmHelper.sharedInstance.realm.objects(Word.self).count
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
       
        var word = Word()
       
        if (searchController.isActive && searchController.searchBar.text != ""){
            word = filteredWords[indexPath.row]
        }
        else{
            word = allWords[indexPath.row] //wenn nichts gesucht wird, alle Woerter anzeigen
        }
        
        cell.textLabel?.text = word.name
        cell.detailTextLabel?.text = word.translation
      
        return cell
    }
    
    
    //Wenn Wort ausgewaehlt wird, kommt man zur edit page des Wortes
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if(searchController.isActive && searchController.searchBar.text != ""){
            showWord(word: filteredWords[indexPath.row])
        }
        else{
            showWord(word: allWords[indexPath.row])
        }
    }
    
  
    func showWord(word: Word){
        let editWordController = EditWordController()
        editWordController.word = word
        self.navigationController?.pushViewController(editWordController, animated: true)
        
    }
    
    
    //Wenn es noch keine Wörter gibt, wird in dieser tableView auch nichts angezeigt
    override func titleForEmptyDataSet(in scrollView: UIScrollView) -> NSAttributedString? {
        return nil
    }
    
    override func descriptionForEmptyDataSet(in scrollView: UIScrollView) -> NSAttributedString? {
        return nil
    }
    

}


extension SearchController: UISearchResultsUpdating {
    
    //inform SearchController about changes in the searchBar
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
      updateSearchResults(for: searchController)
        
    }
    
}





 
