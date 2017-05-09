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

    var itemlist = [(id: Int64, text: String, done: Bool)]()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var newToDo: UITextField!
    
    private var database: Connection?
    let todolist = Table("todolist")
    let id = Expression<Int64>("id")
    let todo = Expression<String>("todo")
    var done = Expression<Bool>("done")
    
    @IBAction func doneToDo(_ sender: UISwitch) {
        let indexPath = IndexPath(row: sender.tag, section: 0)
        
        guard let cell = self.tableView.cellForRow(at: indexPath) as? ToDoItemCell else {
            return
        }
        
        // update database
        let updateToDo = itemlist[indexPath.row]
        let row = todolist.filter(id == updateToDo.id)
        print(updateToDo)
        print(row)
        
        let value = sender.isOn

        do {
            cell.doneSwitch.setOn(value, animated: true)
            try database?.run(row.update(done <- value))
        } catch{
            print("error1")
        }
    }

    @IBAction func addItemButton(_ sender: Any) {
        let insert = todolist.insert(todo <- newToDo.text!, done <- false)

        do {
            let rowId = try database!.run(insert)
            
            do {
                for todos in try database!.prepare(todolist.filter(id == rowId)){
                    itemlist.append((
                        id:   todos[id],
                        text: todos[todo],
                        done: todos[done]
                    ))
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
            for todos in try database!.prepare(todolist){
                itemlist.append((
                    id:   todos[id],
                    text: todos[todo],
                    done: todos[done]
                ))
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
        
        cell.itemLabel.text = itemlist[indexPath.row].text
        cell.doneSwitch.isOn = itemlist[indexPath.row].done
        cell.doneSwitch.tag = indexPath.row
        
        cell.selectionStyle = .none
        
        return cell
    }
    
    // http://stackoverflow.com/questions/3309484/uitableviewcell-show-delete-button-on-swipe
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            let deleteToDo = itemlist[indexPath.row]
            let removeToDo = todolist.filter(id == deleteToDo.id)
            
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
            try database!.run(todolist.create(ifNotExists: true) {t in
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
}
