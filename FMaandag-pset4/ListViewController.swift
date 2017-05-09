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
    var done = Expression<Bool>("done")
    
    @IBAction func doneToDo(_ sender: UISwitch) {

    }

    @IBAction func addItemButton(_ sender: Any) {
        let insert = users.insert(todo <- newToDo.text!)
        
        do {
            let rowId = try database!.run(insert)
            
            do {
                for user in try database!.prepare(users.filter(id == rowId)){
                    itemlist.append(user[todo])
                    newToDo.text = nil
                }
            } catch{
                // error handeling
                print("Could not search in database: \(error)")
            }

        } catch{
            // error handeling
            print("Error creating to do: \(error)")
        }
        
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpDatabase()
        
        do{
            for user in try database!.prepare(users){
                itemlist.append(user[todo])
            }
        }catch {
            // error handeling
            print("No data found: \(error)")
        }
   
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
            
            let deleteToDo = itemlist[indexPath.row]
            let removeToDo = users.filter(todo.like(deleteToDo!))
            
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
                t.column(done)
            })
        }
        
        catch {
            // error handeling
            print("Cannot create table: \(error)")
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at:indexPath) as! ToDoItemCell
        
        // var chekking = Int()
        let updateToDo = itemlist[indexPath.row]!
        let row = users.filter(todo.like(updateToDo))
        print(updateToDo)
        print(row)

        do {
            cell.doneSwitch.setOn(true, animated: true)
            try database?.run(row.update(done <- true))
        } catch{
            print("error1")
        }
        
//        if chekking == 0 {
//            do{
//                try database?.run(user.update(done <- false))
//            } catch{
//                print("error2")
//            }
//
//        }
        
        //let cell = tableView.cellForRow(at:indexPath!) as! ToDoItemCell
            //print(cell)

    }
}
