//
//  ImageModelRealm.swift
//  LoremIpsum
//
//  Created by C: Cosmin Anuta on 16/02/2020.
//  Copyright © 2020 C: Cosmin Anuta. All rights reserved.
//

import Foundation
import RealmSwift

class ImageModelRealm: Object
{
    @objc dynamic var id :Int = 0
    @objc dynamic var author :String = ""
    @objc dynamic var image: Data = Data()
    @objc dynamic var downsampledImage: Data = Data()
}
