//
//  ImageDetailsPresenter.swift
//  LoremIpsum
//
//  Created by C: Cosmin Anuta on 16/02/2020.
//  Copyright © 2020 C: Cosmin Anuta. All rights reserved.
//

import Foundation

class ImageDetailsViewModel {
    var imageModel: ImageModelRealm?
    
    init(imageModel: ImageModelRealm?) {
        self.imageModel = imageModel
    }
    
    func getAuthor() -> String {
        return imageModel?.author ?? ""
    }
    
    func getImageData() -> Data {
        return imageModel?.image ?? Data()
    }
}
