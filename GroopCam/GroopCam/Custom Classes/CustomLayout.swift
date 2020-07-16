//
//  CustomLayout.swift
//  GroopCam
//
//  Created by Zubair on 24/06/20.
//  Copyright © 2020 NJ. All rights reserved.
//

import Foundation
class CustomLayout: UICollectionViewFlowLayout {
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes = super.layoutAttributesForElements(in: rect)?
            .map { $0.copy() } as? [UICollectionViewLayoutAttributes]
        
        attributes?
            .reduce([CGFloat: (CGFloat, [UICollectionViewLayoutAttributes])]()) {
                guard $1.representedElementCategory == .cell else { return $0 }
                return $0.merging([ceil($1.center.y): ($1.frame.origin.y, [$1])]) {
                    ($0.0 < $1.0 ? $1.0 : $0.0, $0.1 + $1.1)
                }
        }
        .values.forEach { minY, line in
            line.forEach {
                $0.frame = $0.frame.offsetBy(dx: 0, dy: $0.frame.origin.y - minY)
            }
        }
        
        return attributes
    }
}
