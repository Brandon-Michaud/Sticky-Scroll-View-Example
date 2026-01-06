//
//  ReplaceStickyTransformer.swift
//  StickyScrollView
//
//  Created by Brandon Michaud on 1/5/26.
//

import SwiftUI

/// A transformer that will replace previous sticky views
struct ReplaceStickyTransformer: StickyTransforming {
    let axis: Axis
    let scrollContainerEnd: CGFloat
    let safeAreaInset: CGFloat
    let frame: StickyFrame
    let otherFrames: [StickyFrame]
    
    init(
        axis: Axis,
        scrollContainerEnd: CGFloat,
        safeAreaInset: CGFloat,
        frame: StickyFrame,
        otherFrames: [StickyFrame]
    ) {
        self.axis = axis
        self.scrollContainerEnd = scrollContainerEnd
        self.safeAreaInset = safeAreaInset
        self.frame = frame
        self.otherFrames = otherFrames
    }
    
    /// If the view should be sticking
    var isSticking: Bool {
        switch frame.edge {
        case .starting:
            switch axis {
            case .horizontal:
                return frame.frame.minX < stickingThreshold
            case .vertical:
                return frame.frame.minY < stickingThreshold
            }
        case .ending:
            switch axis {
            case .horizontal:
                return frame.frame.maxX > stickingThreshold
            case .vertical:
                return frame.frame.maxY > stickingThreshold
            }
        }
    }
    
    /// The minimum/maximum value below/above which a view will stick
    var stickingThreshold: CGFloat {
        switch frame.edge {
        case .starting:
            return .zero - safeAreaInset
        case .ending:
            return scrollContainerEnd + safeAreaInset
        }
    }
        
    /// The offset needed to keep the view visible
    var offset: CGSize {
        // Do not offset if this view is not yet sticking
        guard isSticking else { return CGSize.zero }
        
        switch frame.edge {
        case .starting:
            switch axis {
            case .horizontal:
                // Offset so view is at the leading edge
                var offset = stickingThreshold - frame.frame.minX
                
                // Find first frame to the right of this view that would collide and
                // calculate offset to prevent that
                if let other = otherFrames.first(where: { value in
                    value.edge == frame.edge && value.frame.minX > frame.frame.minX
                        && value.frame.minX - stickingThreshold < frame.frame.width
                }) {
                    offset -= frame.frame.width + stickingThreshold - other.frame.minX
                }
                
                return CGSize(width: offset, height: .zero)
            case .vertical:
                // Offset so view is at the top edge
                var offset = stickingThreshold - frame.frame.minY
                
                // Find first frame below this view that would collide and
                // calculate offset to prevent that
                if let other = otherFrames.first(where: { value in
                    value.edge == frame.edge && value.frame.minY > frame.frame.minY
                        && value.frame.minY - stickingThreshold < frame.frame.height
                }) {
                    offset -= frame.frame.height + stickingThreshold - other.frame.minY
                }
                
                return CGSize(width: .zero, height: offset)
            }
        case .ending:
            switch axis {
            case .horizontal:
                // Offset so view is at the trailing edge
                var offset = stickingThreshold - frame.frame.maxX
                
                // Find first frame to the left of this view that would collide and
                // calculate offset to prevent that
                // TODO: There is a bug here because every single sticking frame with find the same "other"
                // TODO: We really need the "other" frame with the maximum minX
                if let other = otherFrames.first(where: { value in
                    value.edge == frame.edge && value.frame.minX < frame.frame.minX
                        && stickingThreshold - value.frame.maxX < frame.frame.width
                }) {
                    offset += frame.frame.width - stickingThreshold + other.frame.maxX
                }
                
                return CGSize(width: offset, height: .zero)
            case .vertical:
                // Offset so view is at the bottom edge
                var offset = stickingThreshold - frame.frame.maxY
                
                // Find first frame above this view that would collide and
                // calculate offset to prevent that
                // TODO: There is a bug here because every single sticking frame with find the same "other"
                // TODO: We really need the "other" frame with the maximum minY
                if let other = otherFrames.first(where: { value in
                    value.edge == frame.edge && value.frame.minY < frame.frame.minY
                        && stickingThreshold - value.frame.maxY < frame.frame.height
                }) {
                    offset += frame.frame.height - stickingThreshold + other.frame.maxY
                }
                
                return CGSize(width: .zero, height: offset)
            }
        }
    }
    
    func stickyTransform<Content: View>(content: Content) -> any View {
        content
            .offset(offset)
    }
}
