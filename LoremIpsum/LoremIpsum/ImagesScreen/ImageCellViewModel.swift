//
//  ImageCellViewModel.swift
//  LoremIpsum
//
//  Created by C: Cosmin Anuta on 16/02/2020.
//  Copyright © 2020 C: Cosmin Anuta. All rights reserved.
//

import Foundation
import PromiseKit


protocol ImageCellViewModelDelegate {
    func didUpdateLoadingState(imageCellViewModel: ImageCellViewModel, loading: Bool)
}

class ImageCellViewModel
{
    private let queue = DispatchQueue(label: "DB Queue")
     var delegate: ImageCellViewModelDelegate?
    var maxPixelSize: CGFloat = 0
    var imageModel: ImageModel
    var shouldStopLoading: Bool = false
    
    init(model: ImageModel, delegate: ImageCellViewModelDelegate? = nil) {
        imageModel = model
        if let delegate = delegate {
            self.delegate = delegate
        }
    }
    
    func author() -> String {
        return imageModel.author
    }
    
    func id() -> Int {
        return Int(imageModel.id) ?? 0
    }
    
    func getImageData() -> Promise<Data> {
        shouldStopLoading = false
        self.delegate?.didUpdateLoadingState(imageCellViewModel: self, loading: true)
        return firstly {
            Promise<Data> { [unowned self] promiseResolver in
                loadImageFromCache { [unowned self] data, error in
                    if self.shouldStopLoading {
                        promiseResolver.reject(MyError())
                        return
                    }
                    if let data = data {
                        promiseResolver.resolve(data, nil)
                        self.delegate?.didUpdateLoadingState(imageCellViewModel: self, loading: false)
                    }
                    else {
                        self.downloadImage(promiseResolver: promiseResolver)
                    }
                }
            }
        }
    }
    
    func stopLoading() {
        shouldStopLoading = true
    }
    
    private func downloadImage(promiseResolver: Resolver<Data>)
    {
        firstly {
            NetworkingManager.shared().image(imageURL: self.imageModel.imageURL)
        }.done { [weak self] data in
            guard let self = self else {
                promiseResolver.reject(MyError())
                return
            }
            
            if self.shouldStopLoading {
                 promiseResolver.reject(MyError())
            }
            
            self.queue.async { [weak self] in
                guard let self = self else {
                    promiseResolver.reject(MyError())
                    return
                }
                
                if self.shouldStopLoading {
                     promiseResolver.reject(MyError())
                }
                
                if let image = UIImage.downsampleImage(withData: data, shouldResize: true, maxPixelSize: self.maxPixelSize)?.addFilter(filter: .Fade) {
                    if self.shouldStopLoading {
                         promiseResolver.reject(MyError())
                    }
                    
                    let imageModelRealm = ImageModelRealm()
                    imageModelRealm.id = self.id()
                    imageModelRealm.author = self.imageModel.author
                    imageModelRealm.image = data
                    
                    if let downsampledImageData = image.pngData()
                    {
                        imageModelRealm.downsampledImage = downsampledImageData
                        promiseResolver.fulfill(downsampledImageData)
                    }
                    RealmManager.shared().save(imageModel: imageModelRealm)
                    self.delegate?.didUpdateLoadingState(imageCellViewModel: self, loading: false)
                }
            }
        }.catch { (error) in
            promiseResolver.reject(MyError())
        }
    }
    
    private func loadImageFromCache(completion: @escaping (Data?, Error?) -> ())
    {
        queue.async { [unowned self] in
            if let imageModel = RealmManager.shared().getImage(id: self.id()) {
                completion(imageModel.downsampledImage, nil)
            } else {
                completion(nil, MyError())
            }
        }
    }
}
