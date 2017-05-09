//
//  ViewController.swift
//  FMaandag-pset4
//
//  Created by Fien Maandag on 05-05-17.
//  Copyright © 2017 Fien Maandag. All rights reserved.
//

import UIKit
import SQLite

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var itemlist = [String?]()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var newToDo: UITextField!
    
    private var database: Connection?
    let users = Table("users")
    let id = Expression<Int64>("id")
    let todo = Expression<String>("todo")
    
    
    @IBAction func addItemButton(_ sender: Any) {
        let insert = users.insert(todo <- newToDo.text!)
        
        do {
            let rowId = try database!.run(insert)
            print(rowId)
        }
        
        catch{
            // error handeling
            print("Error creating to do: \(error)")
        }
        
        do {
            for user in try database!.prepare(users){
                itemlist.append(user[todo])
                print(itemlist)
            newToDo.text = nil
            }
        }
        
        catch{
            // error handeling
            print("Could not search in database: \(error)")
        }
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpDatabase()
        
        self.navigationItem.title = "To Do List"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemlist.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as! ToDoItemCell
        
        cell.itemLabel.text = itemlist[indexPath.row]
        
        return cell
    }
    
    // http://stackoverflow.com/questions/3309484/uitableviewcell-show-delete-button-on-swipe
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            let removeToDo = users.filter(todo.like("%\(itemlist[indexPath.row]!)%"))
            do {
                try database?.run(removeToDo.delete())
                
            }
            catch {
                // error handeling 
                print("Could not remove: \(error)")
            }
            
            itemlist.remove(at: indexPath.row)
            
            // delete the table view row
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    private func setUpDatabase() {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        
        do {
            database = try Connection("\(path)/db.sqlite3")
            createTable()
        }
        catch {
            // error handeling
            print("Cannot connect to database: \(error)")
        }
    }
    
    func createTable() {
        do {
            try database!.run(users.create(ifNotExists: true) {t in
                t.column(id, primaryKey: .autoincrement)
                t.column(todo)
            })
        }
        
        catch {
            // error handeling
            print("Cannot create table: \(error)")
        }
        
    }
}

