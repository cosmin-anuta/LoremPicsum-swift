//
//  RealmManager.swift
//  LoremIpsum
//
//  Created by C: Cosmin Anuta on 16/02/2020.
//  Copyright © 2020 C: Cosmin Anuta. All rights reserved.
//

import Foundation
import RealmSwift

class RealmManager {
    private let maxCacheSize = 50
    private let queue = DispatchQueue(label: "DB Serial Queue")
    private static var sharedInstance = RealmManager()
    static func shared() -> RealmManager {
        return sharedInstance
    }
    private init() { }
    
    func save(imageModel: ImageModelRealm) {
        queue.async {
            autoreleasepool {
                if imageModel.isInvalidated  { return }
                        
                let realm = try! Realm()
                
                if let savedImage = self.getImage(id: imageModel.id), let cacheDetails = self.getCacheDetails(id: imageModel.id), !savedImage.isInvalidated && !cacheDetails.isInvalidated  {
                    try! realm.write {
                        savedImage.id = imageModel.id
                        savedImage.image = imageModel.image
                        savedImage.downsampledImage = imageModel.downsampledImage
                        savedImage.author = imageModel.author
                    
                        cacheDetails.shouldClean = false
                        cacheDetails.storeTime = Date.init()
                    }
                } else {
                    let cacheDetails = ImageCacheDetailsRealm()
                    cacheDetails.id = imageModel.id
                    cacheDetails.shouldClean = false
                    cacheDetails.storeTime = Date.init()
                    
                    try! realm.write {
                        realm.add(imageModel)
                        realm.add(cacheDetails)
                    }
                }
                self.cleanupCache()
            }
        }
    }
    
    func getImage(id: Int) -> ImageModelRealm? {
        let realm = try! Realm()
        
        if let imageModel = realm.objects(ImageModelRealm.self).filter("id == \(id)").first {
            queue.async {
                autoreleasepool { [unowned self] in
                    let realm = try! Realm()
                    if let cachedDetails = self.getCacheDetails(id: id) {
                        try! realm.write {
                            cachedDetails.storeTime = Date.init()
                        }
                    }
                }
            }
            return imageModel
        }
        
        return nil
    }
    
    func getCacheDetails(id: Int) -> ImageCacheDetailsRealm?
    {
        let realm = try! Realm()
        return realm.objects(ImageCacheDetailsRealm.self).filter("id == \(id)").first
    }
    
    // Only keep last 'maxCacheSize' loaded items
    func cleanupCache() {
        let realm = try! Realm()
        let cacheDetails = realm.objects(ImageCacheDetailsRealm.self).sorted(by: { $0.storeTime > $1.storeTime })
        
        if cacheDetails.count > maxCacheSize
        {
            let ids = cacheDetails.map { $0.id }
            let splitByItem = ids[maxCacheSize - 1]
            
            if let idsToDelete = ids.split(separator: splitByItem).last {
                let objectsToDelete = Array(realm.objects(ImageModelRealm.self)).filter({idsToDelete.contains($0.id)})
                let cacheDetailsToDelete = Array(realm.objects(ImageCacheDetailsRealm.self)).filter({idsToDelete.contains($0.id)})
                
                try! realm.write {
                    for object in objectsToDelete
                    {
                        realm.delete(object)
                    }
                    for cacheDetails in cacheDetailsToDelete
                    {
                        realm.delete(cacheDetails)
                    }
                }
            }
            
        }
    }
}
