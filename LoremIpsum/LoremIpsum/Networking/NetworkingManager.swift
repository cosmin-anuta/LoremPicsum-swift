//
//  NetworkingManager.swift
//  LoremIpsum
//
//  Created by C: Cosmin Anuta on 15/02/2020.
//  Copyright © 2020 C: Cosmin Anuta. All rights reserved.
//

import Foundation
import Alamofire
import PromiseKit

class MyError: Error { }

class NetworkingManager {
    private let queue = DispatchQueue(label: "Networking Serial Queue")

    private static var sharedInstance = NetworkingManager()
    static func shared() -> NetworkingManager {
        return sharedInstance
    }

    private init() { }
    
    func imageList(page: Int, limit: Int) -> Promise<[ImageModel]> {
        let q = DispatchQueue.global()
        let api = ImageListApi(page: page, limit: limit)
        return firstly {
            Alamofire.request(api, method: api.method, parameters: api.parameters, encoding: URLEncoding(destination: .queryString), headers: api.headers()).responseData()
            }
            .map(on: q) { data, response in
               return try JSONDecoder().decode([ImageModel].self, from: data)
            }
    }
    
    func image(imageURL: URLConvertible) -> Promise<Data> {
        return firstly {
            Alamofire.request(imageURL).responseData()
        }.map(on: queue) { data, response in
            return data
        }.ensure {
            
        }
    }

}
