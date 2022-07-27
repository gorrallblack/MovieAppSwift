//
//  UIImageViewExt.swift
//  
//
//  Created by  on 18/01/2021.
//

import Foundation
import Kingfisher

extension UIImageView {
    func setImage(with urlString: String){
        let escapedString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        print(escapedString!)
        
        guard let url = URL.init(string: escapedString ?? "") else {
            return
        }
        let resource = ImageResource(downloadURL: url, cacheKey: urlString)
        var kf = self.kf
        kf.indicatorType = .activity
        self.kf.setImage(with: resource)
    }
}
