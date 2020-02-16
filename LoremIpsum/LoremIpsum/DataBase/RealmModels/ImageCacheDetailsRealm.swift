//
//  File.swift
//  LoremIpsum
//
//  Created by C: Cosmin Anuta on 16/02/2020.
//  Copyright © 2020 C: Cosmin Anuta. All rights reserved.
//

import Foundation
import RealmSwift

class ImageCacheDetailsRealm: Object
{
    @objc dynamic var id: Int = 0
    @objc dynamic var shouldClean: Bool = false
    @objc dynamic var storeTime = Date()
}
