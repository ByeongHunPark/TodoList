//
//  TodoListViewModel.swift
//  TodoList
//
//  Created by 박병훈 on 4/29/24.
//

import Foundation
import UIKit

class TodoListViewModel {
    var todoList: [ListModel] = [] {
        didSet {
            reloadData?()
        }
    }
    
    var reloadData: (() -> Void)?
    
    var textBgViewYValue = CGFloat(0)
    var textFieldViewYValue = CGFloat(0)
    var tableCount : Int = 20
    var page : Int = 1
    var isFetching : Bool = false
    
    var add : String = ""
}
