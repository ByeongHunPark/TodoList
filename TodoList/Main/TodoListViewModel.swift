//
//  TodoListViewModel.swift
//  TodoList
//
//  Created by 박병훈 on 4/29/24.
//

import Foundation
import UIKit

class TodoListViewModel {
//    var scan: Scan {
//        didSet {
//            if editEnable {
//                print("scan setted. oldValue: \(String(describing: oldValue))")
//                if (((scan.uploadFlag == .completed && oldValue.uploadFlag == .completed)
//                     || scan.uploadFlag == .modifyfailed
//                     || (scan.uploadFlag == .backupCompleted && oldValue.uploadFlag == .backupCompleted)
//                    )
//                ) {
//                    scan.uploadFlag = .modify
//                }
//                print("scan setted. data: \(String(describing: scan))")
//            }
//        }
//    }
    
    
    var todoList: [ListModel] = []
//    {
//        didSet{
//            TodoAPI.shared.list { [ self] listModel in
//                self?.todoList = listModel
//            }
//        }
//    }
    
    var searchTodoList: [ListModel] = []
    
    var textFieldViewYValue = CGFloat(0)
    var tableCount : Int = 0
    var page : Int = 20
    
}
