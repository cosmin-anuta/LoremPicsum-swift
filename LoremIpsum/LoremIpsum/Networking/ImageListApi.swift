//
//  ImageListApi.swift
//  LoremIpsum
//
//  Created by C: Cosmin Anuta on 15/02/2020.
//  Copyright © 2020 C: Cosmin Anuta. All rights reserved.
//

import Foundation
import Alamofire

struct APIParameterKey {
    static let page = "page"
    static let limit = "limit"
}

class ImageListApi: APIConfiguration {
    
    var method = HTTPMethod.get
    var path = "https://picsum.photos/v2/list"
    private var page : Int
    private var limit : Int
    
    init(page: Int, limit: Int) {
        self.page = page
        self.limit = limit
    }
    
    var parameters: Parameters? {
        get {
            return [APIParameterKey.page : String(page),
                    APIParameterKey.limit: String(limit)]
        }
    }
    
    func asURL() throws -> URL {
        var stringUrl = path
        if let parameters = parameters
        {
            stringUrl.append("?")
            for key in parameters.keys
            {
                if let value = parameters[key]
                {
                    stringUrl.append("\(key)=\(value)&")
                }
            }
            stringUrl.removeLast()
        }
        
        return try path.asURL()
    }
    
    
}
