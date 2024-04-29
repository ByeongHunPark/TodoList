////
////  Const.swift
////  TodoList
////
////  Created by 박병훈 on 4/27/24.
////
//
import Foundation
import UIKit

final class Const {
//    static let realmExecutor = RealmExecutor()
//    static let fileExecutor = FileExecutor()
//    static let networkExecutor = FiniViewNetwork.shared
    
    // MARK: - Network
//    static var APIAddr: URL {
//        get {
//            return URL(string: "http://127.0.0.1:8080")!
//        }
//    }
    
    static var APIAddr: String {
        get {
            return "http://127.0.0.1:8080"
        }
    }
    
    
//    static var method: Method {
//        switch self {
//        case .list:
//            return .get
//        case .add:
//            return .post
//        case .detail:
//            return .get
//        case .edit:
//            return .put
//        default:
//            return .post
//        }
//    }
//    
//    static var path: String {
//        switch self {
//        case .list:
//            return APIAddr + "/todo/list"
//        case .add:
//            return APIAddr + "/todo"
//        case .detail:
//            return APIAddr + "/todo/%@"
//        case .edit:
//            return APIAddr + "/todo/%@"
//        }
//        
//    }
    
    
}
