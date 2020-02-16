//
//  ImagesViewModel.swift
//  LoremIpsum
//
//  Created by C: Cosmin Anuta on 14/02/2020.
//  Copyright © 2020 C: Cosmin Anuta. All rights reserved.
//

import Foundation
import PromiseKit

protocol ImagesViewModelDelegate
{
    func reloadDataForIndexes(indexPaths: [IndexPath]?)
}

class ImagesViewModel {
    private let itemsPerPage = 10
    private var images: [ImageModel?] = []
    private var fullyLoadedPages : [Int] = []
    private var currentPage = 1
    private var isListFinished: Bool = false
    
    var delegate: ImagesViewModelDelegate?
    
    func numberOfAvailableItems() -> Int {
        return images.count
    }
    
    func numberOfRows() -> Int {
        return isListFinished ? numberOfAvailableItems() : 1000
    }
    
    func imageCellViewModel(forIndex index: Int) -> ImageCellViewModel? {
        guard images.count > index, let model = images[index] else {
            
            return nil
        }

        return ImageCellViewModel(model: model)
    }
    
    func imageDetailsViewModel(atIndex index: Int) -> ImageDetailsViewModel? {
        let imageModel = images[index]
        let id = Int(imageModel?.id ?? "0") ?? 0
        return ImageDetailsViewModel(imageModel: RealmManager.shared().getImage(id: id))
    }
    
    private func getUnloadedPages(forIndexPaths indexPaths: [IndexPath]) -> [Int] {
        var pages = [Int]()
        for indexPath in indexPaths {
            let page: Int = (indexPath.row / itemsPerPage) + 1
            if !pages.contains(page) && !fullyLoadedPages.contains(page) {
                pages.append(page)
            }
        }
        
        return pages
    }
    
    func getData(forIndedPaths indexPaths: [IndexPath]?) {
        guard let indexPaths = indexPaths
            else {
                return
        }
        
        let unloadedPages = getUnloadedPages(forIndexPaths: indexPaths)
        
        for page in unloadedPages {
            updateDataSource(withImageModels: Array<ImageModel?>(repeating: ImageModel.empty(), count: itemsPerPage), forPage: page, shouldReplace: false)
            firstly {
                NetworkingManager.shared().imageList(page: page, limit: itemsPerPage)
            }.done { imageModels in
                DispatchQueue.main.async { [unowned self] in
                    self.updateDataSource(withImageModels: imageModels, forPage: page, shouldReplace: true)
                    if !self.fullyLoadedPages.contains(page) {
                        self.fullyLoadedPages.append(page)
                    }
                    self.delegate?.reloadDataForIndexes(indexPaths: self.indexesToReload(forPage: page))
                }
            }.catch { error in
                print("There has been an error")
            }
        }
    }
    
    private func updateDataSource(withImageModels imageModels: [ImageModel?], forPage page: Int, shouldReplace: Bool) {
        //TODO: Handle end of array case
        let inferiorEdge = (page - 1) * itemsPerPage
        let superiorEdge = page * itemsPerPage
        
        if images.count >= superiorEdge {
            let range = inferiorEdge..<superiorEdge
            if (shouldReplace) {
                images.replaceSubrange(range, with: imageModels)
            }
        }
        else if images.count >= inferiorEdge {
            let range = inferiorEdge..<images.count
            if (shouldReplace) {
                images.replaceSubrange(range, with: imageModels)
            }
            let replacedItems = images.count - inferiorEdge
            images.append(contentsOf: imageModels[replacedItems...])
        } else {
            let emptyItems = Array<ImageModel?>(repeating: nil, count: inferiorEdge - images.count)
            images.append(contentsOf: emptyItems)
            images.append(contentsOf: imageModels)
        }
    }
    
    private func indexesToReload(forPage page: Int) -> [IndexPath] {
        let inferiorEdge = (page - 1) * itemsPerPage
        let superiorEdge = page * itemsPerPage
        return (inferiorEdge..<superiorEdge).map { IndexPath(row: $0, section: 0) }
    }
}

