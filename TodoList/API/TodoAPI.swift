////
////  TodoAPI.swift
////  TodoList
////
////  Created by 박병훈 on 4/27/24.
////
//
import Foundation
import UIKit
import SwiftyJSON
import Alamofire
//
class TodoAPI: ObservableObject{
    
    static let shared = TodoAPI()
    let url = Const.APIAddr
    private init(){
        
    }
    
    func downloadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        AF.request(url).responseData { response in
            guard let data = response.data else {
                let image = UIImage(systemName: "photo")
                completion(image)
                return
            }
            let image = UIImage(data: data)
            completion(image)
        }
    }
    
    func list(completion: @escaping ([ListModel]) -> Void){
        let url = URL(string: url + "/todo/list")!
        
        AF.request(url, method: .get)
            .validate()
            .responseData { response in
                switch response.result{
                case .success(let data):
                    do{
                        let json = try JSON(data: data)
                        
                        guard let results = json["results"].arrayObject as? [[String: Any]] else {
                            completion([])
                            return
                        }
                        
                        var listModels = [ListModel]()
                        
                        let group = DispatchGroup()
                        let queue = DispatchQueue(label: "imageDownloadQueue", attributes: .concurrent)
                        
                        for result in results {
                            if let id = result["id"] as? String,
                               let assignee = result["assignee"] as? String,
                               let create_at = result["createAt"] as? String,
                               let content = result["content"] as? String,
                               let thumbnail = result["contentImage"] as? String,
                               let thumbnailUrl = URL(string: thumbnail)
                            {
//                                group.enter()
                                
//                                queue.async(group: group) {
                                    self.downloadImage(from: thumbnailUrl) { thumbnailImage in
                                        if let thumbnailImage = thumbnailImage{
                                            let listModel = ListModel(id: id,
                                                                      assignee: assignee,
                                                                      create_at: create_at,
                                                                      content: content,
                                                                      thumbnail: thumbnailImage
                                                                      
                                            )
                                            
//                                            DispatchQueue.main.async(flags: .barrier) {
//                                                objc_sync_enter(listModels)
//                                                listModels.append(listModel)
//                                                objc_sync_exit(listModels)
//                                            }
                                        }
                                        
//                                        group.leave()
                                    }
//                                }
                            }
                        }
                        completion(listModels)
                        
//                        group.notify(queue: .main) {
//                            let sortedApps = results.compactMap { result -> ListModel? in
//                                guard let name = result["trackName"] as? String else {
//                                    return nil
//                                }
//                                return listModels.first { $0.assignee == name }
//                            }
//                            
//                            completion(sortedApps)
//                        }
                        
                    }catch {
                        print("Error: \(error)")
                        completion([])
                    }
                case .failure(let error):
                    print("Error: \(error)")
                    completion([])
                }
            }
    }
    
    
    
}
