//
//  AsyncImage.swift
//  BitriseATV
//
//  Created by Vladislav Sosiuk on 02.10.2020.
//  Copyright © 2020 Bitrise. All rights reserved.
//

import SwiftUI
import struct Kingfisher.KFImage

struct AsyncImage: View {
    
    var url: URL?
    
    private var configurations = [(KFImage) -> KFImage]()
    
    init(url: URL?) {
        self.url = url
    }
    
    var body: some View {
        configurations.reduce(KFImage(url), { result, configuration in
            configuration(result)
        })
    }
}

struct AsyncImage_Previews: PreviewProvider {
    static var previews: some View {
        AsyncImage(url: nil)
    }
}

extension AsyncImage {
    
    private func configure(_ block: @escaping (KFImage) -> KFImage) -> AsyncImage {
        var result = self
        result.configurations.append(block)
        return result
    }
    
    func resizable() -> AsyncImage {
        configure { image in
            image.resizable()
        }
    }
    
    func placeholder(_ placeholder: Image) -> AsyncImage {
        configure { image in
            image
                .placeholder {
                    placeholder
                }
        }
    }
}
