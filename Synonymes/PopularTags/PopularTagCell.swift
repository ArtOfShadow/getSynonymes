//
//  PopularTagCell.swift
//  Synonymes
//
//  Created by  Shadow on 08.01.18.
//  Copyright © 2018  Shadow. All rights reserved.
//

import UIKit

class PopularTagCell: UITableViewCell {
    @IBOutlet weak var lblPopularTag: UILabel!
    @IBOutlet weak var lblPopularTagIdx: UILabel!
    
    var model = SynonymsModel()
    
    
    func setupCell (_ popularTag: (idx: Int, name: String)){
       lblPopularTag.text = popularTag.name
       lblPopularTagIdx.text =  String (popularTag.idx)
    }
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}
