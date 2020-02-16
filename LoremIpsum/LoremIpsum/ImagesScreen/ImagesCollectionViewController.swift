//
//  File.swift
//  LoremIpsum
//
//  Created by C: Cosmin Anuta on 14/02/2020.
//  Copyright © 2020 C: Cosmin Anuta. All rights reserved.
//

import Foundation
import UIKit
import PromiseKit

class ImagesCollectionViewController: UICollectionViewController {
    
    let imageDetailSegue = "imageDetailsSegue"
    let viewModel = ImagesViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.prefetchDataSource = self
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let width = view.frame.width/2 - 10
            layout.itemSize = CGSize(width: width, height: width)
            layout.minimumInteritemSpacing = 10
            layout.minimumLineSpacing = 10
            
            collectionView.setCollectionViewLayout(layout, animated: false)
        }
        
        viewModel.delegate = self
        viewModel.getData(forIndedPaths: [IndexPath(item: 0, section: 0)])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == imageDetailSegue {
            if let cell = sender as? UICollectionViewCell
            {
                if let index = collectionView.indexPath(for: cell)?.row
                {
                    let viewController = segue.destination as? ImageDetailsViewController
                    viewController?.viewModel = viewModel.imageDetailsViewModel(atIndex: index)
                }
            }
        }
    }
}

extension ImagesCollectionViewController: ImagesViewModelDelegate {
    func reloadDataForIndexes(indexPaths: [IndexPath]?) {
        guard let indexPaths = indexPaths else {
            collectionView.reloadData()
            return
        }
        
        let indexPathsForVisibleRows = collectionView.indexPathsForVisibleItems
        let indexPathsIntersection = Set(indexPathsForVisibleRows).intersection(indexPaths)
        collectionView.reloadItems(at: Array(indexPathsIntersection))
    }
    
}

extension ImagesCollectionViewController {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfRows()
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as? ImageCollectionViewCell {
            cell.configure(viewModel: viewModel.imageCellViewModel(forIndex: indexPath.row))
            return cell
        }
        
        return super.collectionView(collectionView, cellForItemAt: indexPath)
    }
}

extension ImagesCollectionViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        if indexPaths.contains(where: { (indexPath) -> Bool in return indexPath.row >= viewModel.numberOfAvailableItems() }) {
            viewModel.getData(forIndedPaths: indexPaths)
        }
    }
    
}
