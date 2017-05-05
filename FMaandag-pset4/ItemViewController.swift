//
//  ItemViewController.swift
//  FMaandag-pset4
//
//  Created by Fien Maandag on 05-05-17.
//  Copyright © 2017 Fien Maandag. All rights reserved.
//

import UIKit

class ItemViewController: UIViewController {

    @IBOutlet weak var fullItemLabel: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "To Do"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
