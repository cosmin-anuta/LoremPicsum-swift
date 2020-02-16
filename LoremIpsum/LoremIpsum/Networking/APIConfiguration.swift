//
//  ImageApi.swift
//  LoremIpsum
//
//  Created by C: Cosmin Anuta on 15/02/2020.
//  Copyright © 2020 C: Cosmin Anuta. All rights reserved.
//

import Foundation
import Alamofire


enum HTTPHeaderField: String {
    case authentication = "Authorization"
    case contentType = "Content-Type"
    case acceptType = "Accept"
    case acceptEncoding = "Accept-Encoding"
}

enum ContentType: String {
    case json = "application/json"
}

protocol APIConfiguration: URLConvertible {
    var method: HTTPMethod { get }
    var path: String { get }
    var parameters: Parameters? { get }
    func headers() -> HTTPHeaders
}

extension APIConfiguration
{
    func headers() -> HTTPHeaders {
        return [HTTPHeaderField.acceptType.rawValue: HTTPHeaderField.contentType.rawValue]
    }
}
