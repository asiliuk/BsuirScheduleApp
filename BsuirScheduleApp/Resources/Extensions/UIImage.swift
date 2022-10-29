//
//  UIImage.swift
//  BsuirScheduleApp
//
//  Created by Nikita Prokhorchuk on 29.10.22.
//  Copyright © 2022 Saute. All rights reserved.
//

import UIKit

// See https://stackoverflow.com/questions/26542035/create-uiimage-with-solid-color-in-swift
extension UIImage {
    convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}
