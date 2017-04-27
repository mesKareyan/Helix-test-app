//
//  NetworkManager.swift
//  Mesrop-Test-App
//
//  Created by Mesrop Kareyan on 4/25/17.
//  Copyright © 2017 Mesrop Kareyan. All rights reserved.
//

import UIKit

enum RequestResult {
    case success(with: Any)
    case fail(with: Error)
}

enum InternalError: Error {
    case badResponse
}

class NetworkManager {
    
    static let shared = NetworkManager()
    private init () {}
    
    private struct Constants {
        private init() {}
        static let baseURL = URL(string: "https://www.helix.am/temp/json.php")!
    }
    
    typealias NetworkRequestCompletion = (RequestResult) -> ()
    
    func getAllNews(completion: @escaping NetworkRequestCompletion) {
        var request = URLRequest(url: Constants.baseURL)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                DispatchQueue.main.async {
                    completion(.fail(with: error!))
                }
                return
            }
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.fail(with: InternalError.badResponse))
                }
                return
            }
            let result = ApiRequestSerialization.resultFor(response: response, data: data)
            completion(result)
        }
        task.resume()
    }
    
    //MARK: - Images async donwload
    func downloadImage(at urlString: String, completion: @escaping (_ image: UIImage?) -> ()) {
        guard let url = URL(string: urlString) else {
            DispatchQueue.main.async() {
                completion(nil)
            }
            return
        }
        getDataFrom(url: url) { (data, response, error)  in
            guard let data = data, error == nil else {
                DispatchQueue.main.async() {
                    completion(nil)
                }
                return
            }
            let image =  UIImage(data: data)
            DispatchQueue.main.async() {
                completion(image)
            }
        }
    }
    
    private func getDataFrom(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
        URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            completion(data, response, error)
            }.resume()
    }
    
}

class ApiRequestSerialization {
    
    private init() {}
    
    fileprivate static func resultFor(response: URLResponse?,
                                                 data: Data) -> RequestResult {
        if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
            // check for http errors
            return .fail(with: InternalError.badResponse)
        }
        do {
            guard let jsonDict = try JSONSerialization.jsonObject(with: data,
                                                                  options: .allowFragments)
                as? [String : Any],
                let successValue = jsonDict["success"] as? Bool,
                successValue == true,
            let meta = jsonDict["metadata"] as? [Any]
                else {
                    return .fail(with: InternalError.badResponse)
            }
            let news = meta.map { metaData in NewsItem(with: metaData as! [String : Any]) }
            return .success(with: news)
        }
        catch
        {
            return .fail(with: InternalError.badResponse)
        }
    }
}
