//
//  MainController.swift
//  Synonymes
//
//  Created by  Shadow on 05.01.18.
//  Copyright © 2018  Shadow. All rights reserved.
//

import UIKit


class MainController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
   
    @IBOutlet weak var textForSend: UITextField!
    @IBOutlet weak var textViewSynonyms: UITextView!
    @IBOutlet weak var total: UILabel!
    @IBOutlet weak var lblCurrentWord: UILabel!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var tablePopular: UITableView!
    @IBOutlet weak var progress: UIProgressView!
    
    
    var model = SynonymsModel()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        tablePopular.delegate = self
        tablePopular.dataSource = self
        
        textViewSynonyms.isEditable = false
        
        model.senderVC = self
        model.addEvent()
        
    }
    
    
    /// heightForRowAt
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 22
    }
    
    
    /// 've choosen the cell with popular tag
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            model.getSelectedPopularTag (at: indexPath.row, view: self)
    }
    
    /// numberOfRowsInSection
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.popularTagsList.count
    }
    
    /// cellForRowAt indexPath
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "cellForPopularTags") as? PopularTagCell {
            cell.setupCell( model.popularTagsList[indexPath.row] )
            return cell
        } else { return PopularTagCell() }
        
    }
    

    /// Fill the table with popular tags from CSV
    @IBAction func onLoadBtnTapped(_ sender: UIButton) {
        model.readFileOfPopularTags(self) { (complete) in
            tablePopular.reloadData()
        }
    }
    
    
    /// Entered any tag into textField AND presssed send
    @IBAction func onBtnAddPopularTapped(_ sender: UIButton) {

        guard let word = textForSend.text else {return}

        model.clearTheTextAndResignFirstResponder(self)
        
        model.sendRequest { (true) in
            print ("true")
        }

    }
    
    
    
    @IBAction func taptaptap(_ sender: Any) {
        model.readFileOfPopularTags(self) { (complete) in
            tablePopular.reloadData()
        }
        model.saveToFile()
    }
    
    
    
    
    
    
    
    
    
    
    
}

