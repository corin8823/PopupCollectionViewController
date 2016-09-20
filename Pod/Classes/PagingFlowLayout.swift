//
//  PagingFlowLayout.swift
//  PopupCollectonViewController
//
//  Created by corin8823 on 4/9/16.
//  Copyright (c) 2015 corin8823. All rights reserved.
//

import UIKit

public protocol PagingFlowLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, layout pagingFlowLayout: PagingFlowLayout, changePage page: Int)
}

open class PagingFlowLayout: UICollectionViewFlowLayout {

    open var pagingDelegate: PagingFlowLayoutDelegate?

    override open func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {

        guard let collectionView = self.collectionView else {
            return super.targetContentOffset(forProposedContentOffset: proposedContentOffset)
        }

        guard let attributes = self.layoutAttributesForElements(in: collectionView.bounds) else {
            return .zero
        }
        let proposeCenterX = proposedContentOffset.x + collectionView.bounds.size.width * 0.5
        var candidateAttribute: UICollectionViewLayoutAttributes!
        attributes.forEach {
            if $0.representedElementCategory != .cell {
                return
            }

            guard let candidate = candidateAttribute else {
                candidateAttribute = $0
                return
            }
            let leftOffset = fabsf(Float($0.center.x - proposeCenterX))
            let rightOffset = fabsf(Float(candidate.center.x - proposeCenterX))

            if velocity.x < 0 {
                return
            } else if velocity.x > 0 {
                candidateAttribute = $0
            } else if leftOffset < rightOffset {
                candidateAttribute = $0
            }
        }

        var proposedX = round(candidateAttribute.center.x - collectionView.bounds.size.width * 0.5)
        proposedX = max(proposedX, 0)
        proposedX = min(proposedX, round(self.collectionViewContentSize.width - collectionView.bounds.size.width))
        let currentPage = Int(round(proposedX / (candidateAttribute.bounds.size.width + self.minimumInteritemSpacing)))
        self.pagingDelegate?.collectionView(collectionView, layout: self, changePage: currentPage)
        return CGPoint(x: proposedX, y: proposedContentOffset.y)
    }
}
