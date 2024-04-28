////
////  TodoAPI.swift
////  TodoList
////
////  Created by 박병훈 on 4/27/24.
////
//
//import Foundation
//import UIKit
////import SwiftyJSON
//import Alamofire
//
//class TodoAPI: ObservableObject{
//    
//    static let shared = TodoAPI()
//    let url = Const.path
//    let method = Const.method
//    private init(){
//        
//    }
//    
//    func downloadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
//        AF.request(url).responseData { response in
//            guard let data = response.data else {
//                completion(nil)
//                return
//            }
//            let image = UIImage(data: data)
//            completion(image)
//        }
//    }
//    
//    func list(){
//        AF.request(url.list, method: method.list)
//            .validate()
//            .responseData { response in
//                switch response.result{
//                case .success(let data):
//                    do{
//                        let json = try JSON(data: data)
//                        
//                        guard let results = json["results"].arrayObject as? [[String: Any]] else {
//                            completion([])
//                            return
//                        }
//                        
//                        var apps = [App]()
//                        
//                        let group = DispatchGroup()
//                        let queue = DispatchQueue(label: "imageDownloadQueue", attributes: .concurrent)
//                        
//                        for result in results {
//                            if let name = result["trackName"] as? String,
//                               let rating = result["averageUserRating"] as? Double,
//                               let userRatingCount = result["userRatingCount"] as? Int,
//                               let iconUrlString = result["artworkUrl100"] as? String,
//                               let screenshotUrls = result["screenshotUrls"] as? [String],
//                               let iconUrl = URL(string: iconUrlString),
//                               let description = result["description"] as? String,
//                               let releaseNotes = result["releaseNotes"] as? String,
//                               let screenshotUrlString = screenshotUrls.first,
//                               let screenshotUrl = URL(string: screenshotUrlString),
//                               let genres = result["genres"] as? [String],
//                               let genre = genres.first,
//                               let trackContentRating = result["trackContentRating"] as? String
//                            {
//                                group.enter()
//                                
//                                queue.async(group: group) {
//                                    self.downloadImage(from: iconUrl) { iconImage in
//                                        self.downloadImage(from: screenshotUrl) { screenshotImage in
//                                            if let iconImage = iconImage, let screenshotImage = screenshotImage {
//                                                let app = App(name: name,
//                                                              rating: rating,
//                                                              userRatingCount: userRatingCount,
//                                                              iconImage: iconImage,
//                                                              screenshotImage: screenshotImage,
//                                                              screenshotImageUrls: screenshotUrls,
//                                                              releaseNotes: releaseNotes,
//                                                              description: description,
//                                                              genre: genre,
//                                                              trackContentRating: trackContentRating
//                                                              
//                                                )
//                                                
//                                                DispatchQueue.main.async(flags: .barrier) {
//                                                    objc_sync_enter(apps)
//                                                    apps.append(app)
//                                                    objc_sync_exit(apps)
//                                                }
//                                            }
//                                            group.leave()
//                                        }
//                                    }
//                                }
//                            }
//                        }
//                        
//                        group.notify(queue: .main) {
//                            let sortedApps = results.compactMap { result -> App? in
//                                guard let name = result["trackName"] as? String else {
//                                    return nil
//                                }
//                                return apps.first { $0.name == name }
//                            }
//                            
//                            completion(sortedApps)
//                        }
//                        
//                    }catch {
//                        print("Error: \(error)")
//                        completion([])
//                    }
//                case .failure(let error):
//                    print("Error: \(error)")
//                    completion([])
//                }
//            }
//    }
//    
//    
//    
//}
