//
//  ImageModel.swift
//  LoremIpsum
//
//  Created by C: Cosmin Anuta on 14/02/2020.
//  Copyright © 2020 C: Cosmin Anuta. All rights reserved.
//

import Foundation

struct ImageModel: Codable {
    let id: String
    let author: String
    let imageURL: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case author
        case imageURL = "download_url"
    }
    
    static func empty() -> ImageModel?
    {
        return nil
    }
}
