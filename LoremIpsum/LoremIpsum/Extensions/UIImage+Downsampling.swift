//
//  UIImage+Downsampling.swift
//  LoremIpsum
//
//  Created by C: Cosmin Anuta on 16/02/2020.
//  Copyright © 2020 C: Cosmin Anuta. All rights reserved.
//

import UIKit

extension UIImage
{
    static func downsampleImage(withData data:Data, shouldResize: Bool, maxPixelSize: CGFloat) -> UIImage?
    {
        let sourceOptions = [kCGImageSourceShouldCache:false] as CFDictionary
        let source = CGImageSourceCreateWithData(data as CFData, sourceOptions)!
        
        
        var downsampleOptions: CFDictionary
        
        if shouldResize {
            downsampleOptions = [kCGImageSourceCreateThumbnailFromImageAlways:true,
                                 kCGImageSourceThumbnailMaxPixelSize:maxPixelSize,
                                 kCGImageSourceShouldCacheImmediately:true,
                                 kCGImageSourceCreateThumbnailWithTransform:true,
                ] as CFDictionary
        } else {
            downsampleOptions = [kCGImageSourceCreateThumbnailFromImageAlways:true,
                                 kCGImageSourceShouldCacheImmediately:true,
                                 kCGImageSourceCreateThumbnailWithTransform:true,
                ] as CFDictionary
        }
        
        
        if let downsampledImage = CGImageSourceCreateThumbnailAtIndex(source, 0, downsampleOptions)
        {
            return UIImage(cgImage: downsampledImage)
        }
        
        return nil
    }

}
