//
//  ImageDetailsViewController.swift
//  LoremIpsum
//
//  Created by C: Cosmin Anuta on 16/02/2020.
//  Copyright © 2020 C: Cosmin Anuta. All rights reserved.
//

import UIKit

class ImageDetailsViewController: UIViewController {
    var viewModel: ImageDetailsViewModel?
    
    @IBOutlet weak var fullSizeImageView: UIImageView!
    @IBOutlet weak var authorNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let viewModel = viewModel {
            authorNameLabel.text = viewModel.getAuthor()
            fullSizeImageView.image = UIImage(data: viewModel.getImageData())
        }
    }
}
