//
//  TodoListTableViewController.swift
//  HandyList
//
//  Created by Christian Lorenzo on 5/27/20.
//  Copyright © 2020 Christian Lorenzo. All rights reserved.
//

import UIKit
import CoreData
import RealmSwift
import ChameleonFramework

//    This is to open realm /Users/christianlorenzo/Library/Developer/CoreSimulator/Devices/5D88ECDB-6B4F-43F6-A21E-5092B27FD52A/data/Containers/Data/Application/A7663F2E-4891-4638-A619-EAACA4633C5D/Documents/default.realm

class TodoListTableViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    
    var todoItems : Results<Item>?
    
    var selectedCategory: Category? {
        didSet {
            loadItems()
        }
    }
    
    func loadItems() {
        
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
    }
    
    override func updateModel(at indexPath: IndexPath) {
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    realm.delete(item)
                }
            } catch {
                print("Error deleting item, \(error)")
            }
        }
    }
    
    @IBOutlet weak var searchBarOutlet: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //This is how we can see our files, by printing the path.
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        tableView.rowHeight = 80.0
        
        tableView.separatorStyle = .none
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let colourHex = selectedCategory?.colour {
            
            title = selectedCategory!.name
            guard let navBar = navigationController?.navigationBar else { fatalError("Navigation Controller does not exist")}
            
            if let navBarColor = UIColor(hexString: colourHex) {
                navBar.backgroundColor = navBarColor
                
                navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
                
                navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: ContrastColorOf(navBarColor, returnFlat: true)]
                
                searchBarOutlet.barTintColor = navBarColor
            }
            
        }
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        // Configure the cell...
        
        if let item = todoItems?[indexPath.row] {
            
            cell.textLabel?.text = item.title
            
            if let colour = UIColor(hexString: selectedCategory!.colour)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(todoItems!.count)) {
                cell.backgroundColor = colour
                cell.textLabel?.textColor = ContrastColorOf(colour, returnFlat: true)
            }
            //Ternary operator to save the code written on the if else below:
            //value = condition ? valueIfTrue : valueIfFalse
            //cell.accessoryType = item.done == true ? .checkmark : .none
            cell.accessoryType = item.done ? .checkmark : .none
        } else {
            cell.textLabel?.text = "No Items Added"
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 1. The realm.delete is to delete the items inside the list from teh tableView by tapping on the item.
        // 2. This is to handle the Check mark on realm and the tableView
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    //realm.delete(item) // 1.0
                    item.done = !item.done // 2.0
                }
            } catch {
                print("Error saving done status, \(error)")
            }
        }
        
        tableView.reloadData()
        
        tableView.deselectRow(at: indexPath, animated: true) //Deselecting the row when tapped.        
    }
    
    //Function to delete from each cell and from the context too.
    //    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    //        if editingStyle == .delete {
    //            context.delete(itemArray[indexPath.row])
    //            itemArray.remove(at: indexPath.row)
    //            tableView.deleteRows(at: [indexPath], with: .fade)
    //        } else if editingStyle == .insert {
    //
    //        }
    //
    //        saveItems()
    //
    //        tableView.reloadData()
    //    }
    
    //MARK: - Add New Items:
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        //This is what the alert says inside.
        let alert = UIAlertController(title: "Add New HandyList Item!", message: "", preferredStyle: .alert)
        
        //This is the "Add Item" message that has to be tapped in order to add a new item to the list.
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            //What Will happend once the user clicks the Add Item Button on our UIAlert
            //print(textField.text) //We're printing the new category created below.
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                    }
                } catch {
                    print("Error saving new items, \(error)")
                }
            }
            
            self.tableView.reloadData()
        }
        
        //This is to create a textfield inside the alert that will let the User to enter the name of the new Category.
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create New Category"
            textField = alertTextField  //We're assigning the name of the category to the scope variable at the beginning.
        }
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
    }
}
        //MARK: - SearchBar Method:
        
extension TodoListTableViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 { //if there's no characters on the search bar, then it'll bring the rest of the list.
            loadItems()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder() //No cursor on the searchBar.
            }
        }
    }
}

