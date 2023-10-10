//
//  ZenoKFImageView.swift
//  Zeno
//
//  Created by gnksbm on 2023/10/09.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI
import Kingfisher

struct ZenoKFImageView<T: ZenoSearchable>: View {
    let item: T
    let ratio: SwiftUI.ContentMode
    
    var body: some View {
        if let urlStr = item.imageURL,
           let url = URL(string: urlStr) {
            KFImage(url)
                .cacheOriginalImage()
                .resizable()
                .placeholder {
                    Image("ZenoIcon")
                        .resizable()
                }
                .aspectRatio(contentMode: ratio)
        }
    }
    /// 기본 인자로 ZenoSearchable 프로토콜을 채택한 값을 받으며
    /// 추가로 ratio 인자에 .fit으로 aspectRatio를 설정할 수 있고 기본값은 .fill
    init(_ item: T, ratio: SwiftUI.ContentMode = .fill) {
        self.item = item
        self.ratio = ratio
    }
}

class ZenoCacheManager<T: AnyObject> {
    let shared = NSCache<NSString, T>()
    
    func saveImage(url: URL?, image: T) {
        guard let url else { return }
        shared.setObject(image, forKey: url.absoluteString as NSString)
    }
    
    func loadImage(url: URL?) -> T? {
        guard let url,
              let object = shared.object(forKey: url.absoluteString as NSString) as? T
        else { return nil }
        return object
    }
}

struct ZenoKFImageView_Previews: PreviewProvider {
    static var previews: some View {
        ZenoKFImageView(User.fakeCurrentUser)
    }
}
