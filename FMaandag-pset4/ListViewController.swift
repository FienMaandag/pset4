//
//  ViewController.swift
//  FMaandag-pset4
//
//  Created by Fien Maandag on 05-05-17.
//  Copyright © 2017 Fien Maandag. All rights reserved.
//

import UIKit

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var itemlist = ["todo1", "todo2", "todo3"]
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var newToDo: UITextField!
    @IBAction func addItemButton(_ sender: Any) {
        itemlist.append(newToDo.text!)
        newToDo.text = nil
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
            itemlist.remove(at: indexPath.row)
            
            // delete the table view row
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}

