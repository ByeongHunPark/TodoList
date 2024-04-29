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
//    private init(){
//        
//    }
    
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
    
    func list(page: Int, completion: @escaping ([ListModel]) -> Void){
        let url = URL(string: url + "/todo/list?page=\(page)&per=20")!
        
        AF.request(url, method: .get)
            .validate()
            .responseData { response in
                switch response.result{
                case .success(let data):
                    do{
                        let json = try JSON(data: data)
                        
                        let status = json["status"].intValue
                        let success = json["success"].stringValue
                        let message = json["message"].stringValue
                        
                        if status == 200 && success == "TRUE" {
                            let data = json["data"]
                            let metadataData = data["metadata"]
                            let itemsData = data["items"].arrayValue
                            
                            var listModels = [ListModel]()
                            
                            let total = metadataData["total"].intValue
                            let page = metadataData["page"].intValue
                            let per = metadataData["per"].intValue
                            
                            let group = DispatchGroup()
                            let queue = DispatchQueue(label: "imageDownloadQueue", attributes: .concurrent)
                            
                            for item in itemsData {
                                let id = item["id"].stringValue
                                let assignee = item["assignee"].stringValue
                                let create_at = item["createAt"].stringValue
                                let content = item["content"].stringValue
                                let thumbnail = item["contentImage"].stringValue
                                
                                group.enter()
                                
                                if thumbnail != ""{
                                    self.downloadImage(from: URL(string: thumbnail)!) { thumbnailImage in
                                        if let thumbnailImage = thumbnailImage{
                                            let listModel = ListModel(id: id,
                                                                      assignee: assignee,
                                                                      create_at: create_at,
                                                                      content: content,
                                                                      thumbnail: thumbnailImage,
                                                                      total: total,
                                                                      page: page,
                                                                      per: per
                                                                      
                                            )
                                            
                                            listModels.append(listModel)
                                        }
                                        
                                        group.leave()
                                    }
                                }else{
                                    let listModel = ListModel(id: id,
                                                              assignee: assignee,
                                                              create_at: create_at,
                                                              content: content,
                                                              thumbnail: UIImage(systemName: "photo")!,
                                                              total: total,
                                                              page: page,
                                                              per: per
                                                              
                                    )
                                    listModels.append(listModel)
                                    group.leave()
                                }
                            }
                            group.notify(queue: .main) {
                                completion(listModels)
                            }
                                
                            
                        } else {
                            print("요청이 실패했습니다. 메시지: \(message)")
                        }
                        
                        
                    }catch {
                        print("SError: \(error)")
                        completion([])
                    }
                case .failure(let error):
                    print("FError: \(error)")
                    completion([])
                }
            }
    }
    
    
    
}
