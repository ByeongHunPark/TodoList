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
    let baseUrl = Const.APIAddr
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
    
    func list(page: Int, assignee: String? = nil, completion: @escaping ([ListModel]) -> Void){
        var url = URL(string: baseUrl + "/todo/list?page=\(page)&per=20")!
        
        if assignee != nil{
            url = URL(string: baseUrl + "/todo/list?page=\(page)&per=20&assignee=\(assignee!)")!
        }
        
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
                            completion([])
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
    
    func addTodo(assignee: String , content: String, imageFile: UIImage, imageName: String,completion: @escaping (String) -> Void){
        guard let imageData = imageFile.jpegData(compressionQuality: 1.0) else {
            print("이미지 데이터를 변환하는 데 문제가 있습니다.")
            return
        }
        
        let url = URL(string: baseUrl + "/todo")!
        var id = ""
        
        AF.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(Data(assignee.utf8), withName: "assignee")
            multipartFormData.append(Data(content.utf8), withName: "content")
            multipartFormData.append(imageData, withName: "imageFile", fileName: "image/\(imageName)", mimeType: "image/jpeg")
        }, to: url, method: .post)
        .validate()
        .responseData { response in
            switch response.result {
            case .success(let data):
                do{
                    let json = try JSON(data: data)
                    
                    let status = json["status"].intValue
                    let success = json["success"].stringValue
                    let message = json["message"].stringValue
                    
                    if status == 200 && success == "TRUE" {
                        let data = json["data"]
                        let idValue = data["id"].stringValue
                        
                        id = idValue
                    } else {
                        print("요청이 실패했습니다. 메시지: \(message)")
                        completion("실패")
                    }
                }catch {
                    print("SError: \(error)")
                    completion("실패")
                }
                completion(id)
            case .failure(let error):
                print("FError: \(error)")
                completion("실패")
            }
        }
    }
    
    func detail(id: String, completion: @escaping (DetailModel) -> Void){
        let url = URL(string: baseUrl + "/todo/\(id)")!
        
        var detailModel = DetailModel(id: "error", assignee: "error", create_at: "2024-04-30 19:00:00", content: "error", thumbnail: UIImage(systemName: "photo")!)
        
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
                            
                            let id = data["id"].stringValue
                            let assignee = data["assignee"].stringValue
                            let create_at = data["createAt"].stringValue
                            let content = data["content"].stringValue
                            let contentImage = data["contentImage"].stringValue
                            
                            let group = DispatchGroup()
                            let queue = DispatchQueue(label: "imageDownloadQueue", attributes: .concurrent)
                            
                            group.enter()
                            
                            if contentImage != ""{
                                self.downloadImage(from: URL(string: contentImage)!) { thumbnailImage in
                                    if let thumbnailImage = thumbnailImage{
                                        detailModel = DetailModel(id: id,
                                                                  assignee: assignee,
                                                                  create_at: create_at,
                                                                  content: content,
                                                                  thumbnail: thumbnailImage
                                        )
                                    }
                                    
                                    group.leave()
                                }
                            }else{
                                detailModel = DetailModel(id: id,
                                                          assignee: assignee,
                                                          create_at: create_at,
                                                          content: content,
                                                          thumbnail: UIImage(systemName: "photo")!
                                                          
                                )
                                
                                group.leave()
                            }
                            
                            group.notify(queue: .main) {
                                completion(detailModel)
                            }
                            
                        } else {
                            print("요청이 실패했습니다. 메시지: \(message)")
                            completion(detailModel)
                        }
                    }catch {
                        print("SError: \(error)")
                        completion(detailModel)
                    }
                case .failure(let error):
                    print("FError: \(error)")
                    completion(detailModel)
                }
            }
    }
    
    func editDetail(id: String, assignee: String , content: String, completion: @escaping (DetailModel, Bool) -> Void){
        let url = URL(string: baseUrl + "/todo/\(id)")!
        
        let parameters: [String: Any] = [
            "assignee": assignee,
            "content": content
        ]
        
        var detailModel = DetailModel(id: "", assignee: "", create_at: "", content: "", thumbnail: UIImage(systemName: "photo")!)
        
        AF.request(url, method: .put, parameters: parameters)
            .validate()
            .responseData { response in
                switch response.result {
                case .success(let data):
                    do{
                        let json = try JSON(data: data)
                        
                        let status = json["status"].intValue
                        let success = json["success"].stringValue
                        let message = json["message"].stringValue
                        
                        if status == 200 && success == "TRUE" {
                            let data = json["data"]
                            
                            let id = data["id"].stringValue
                            let assignee = data["assignee"].stringValue
                            let create_at = data["createAt"].stringValue
                            let content = data["content"].stringValue
                            let contentImage = data["contentImage"].stringValue
                            
                            let group = DispatchGroup()
                            let queue = DispatchQueue(label: "imageDownloadQueue", attributes: .concurrent)
                            
                            group.enter()
                            
                            if contentImage != ""{
                                self.downloadImage(from: URL(string: contentImage)!) { thumbnailImage in
                                    if let thumbnailImage = thumbnailImage{
                                        detailModel = DetailModel(id: id,
                                                                  assignee: assignee,
                                                                  create_at: create_at,
                                                                  content: content,
                                                                  thumbnail: thumbnailImage
                                        )
                                    }
                                    
                                    group.leave()
                                }
                            }else{
                                detailModel = DetailModel(id: id,
                                                          assignee: assignee,
                                                          create_at: create_at,
                                                          content: content,
                                                          thumbnail: UIImage(systemName: "photo")!
                                                          
                                )
                                
                                group.leave()
                            }
                            
                            group.notify(queue: .main) {
                                completion(detailModel, true)
                            }
                            
                        } else {
                            print("요청이 실패했습니다. 메시지: \(message)")
                            completion(detailModel, false)
                        }
                    }catch {
                        print("SError: \(error)")
                        completion(detailModel, false)
                    }
                case .failure(let error):
                    print("FError: \(error)")
                    completion(detailModel, false)
                }
            }
    }
    
}
