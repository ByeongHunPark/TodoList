//
//  TodoListTableCell.swift
//  TodoList
//
//  Created by 박병훈 on 4/28/24.
//

import Foundation
import UIKit
import SnapKit

class TodoListTableCell: UITableViewCell{
    @IBOutlet weak var thumbnail : UIImageView!
    @IBOutlet weak var assignee : UILabel!
    @IBOutlet weak var create_at : UILabel!
    @IBOutlet weak var content : UILabel!
    
    override func layoutSubviews(){
        super.layoutSubviews()
    }
}
