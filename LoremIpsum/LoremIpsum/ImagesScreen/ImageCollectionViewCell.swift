//
//  ImageCollectionViewCell.swift
//  LoremIpsum
//
//  Created by C: Cosmin Anuta on 14/02/2020.
//  Copyright © 2020 C: Cosmin Anuta. All rights reserved.
//

import UIKit
import PromiseKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var awesomeImageView: UIImageView!
    @IBOutlet weak var authorNameLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var isLoading: Bool = false
    
    let queue = DispatchQueue(label: "DB Queue")
    
    var viewModel: ImageCellViewModel?
    
    func configure(viewModel: ImageCellViewModel?) {
        self.viewModel = viewModel
        let scale = traitCollection.displayScale;
        let maxPixelSize: CGFloat = frame.width * scale;
        viewModel?.maxPixelSize = maxPixelSize
        startLoading()
    }
    
    private func startLoading() {
        guard let viewModel = viewModel
        else
        {
            displayLoadingUI(isLoading: true)
            authorNameLabel.text = ""
            return
        }
        
        authorNameLabel.text = viewModel.author()

       
        firstly {
            viewModel.getImageData()
        }.done { [weak self] data in
            self?.awesomeImageView.image = UIImage.init(data: data)
            self?.displayLoadingUI(isLoading: false)
        }.catch { (error) in
            //TODO: handle errors
        }
    }
    
    private func displayLoadingUI(isLoading: Bool)
    {
        isUserInteractionEnabled = !isLoading
        awesomeImageView.isHidden = isLoading
        activityIndicator.isHidden = !isLoading
        isLoading ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        awesomeImageView.image = nil
        authorNameLabel.text = ""
        displayLoadingUI(isLoading: true)
        viewModel?.stopLoading()
    }
}
