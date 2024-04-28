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
    @IBOutlet var thumbnail : UIImageView!
    @IBOutlet var assignee : UILabel!
    @IBOutlet var create_at : UILabel!
    @IBOutlet var content : UILabel!
    
    override func layoutSubviews(){
        super.layoutSubviews()
//        setLayout()
    }
    
//    private func setLayout(){
//        thumbnail.snp.makeConstraints { make in
////            make.left.equalToSuperview()
////            make.top.equalToSuperview()
//            make.height.equalToSuperview()
//            make.width.equalTo(self.superview!.snp.height)
//        }
//        
//        assignee.snp.makeConstraints { make in
//            make.top.equalTo(thumbnail.snp.top)
//            make.left.equalTo(thumbnail.snp.right).offset(8)
//        }
//        
//        create_at.snp.makeConstraints { make in
//            make.top.equalTo(assignee.snp.bottom).offset(8)
//            make.left.equalTo(assignee.snp.left)
//        }
//        
//        content.snp.makeConstraints { make in
//            make.top.equalTo(create_at.snp.bottom).offset(16)
//            make.left.equalTo(assignee.snp.left)
//        }
//    }
}
