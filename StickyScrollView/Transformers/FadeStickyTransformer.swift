//
//  FadeStickyTransformer.swift
//  StickyScrollView
//
//  Created by Brandon Michaud on 1/5/26.
//

import SwiftUI

/// A transformer that will make previous sticky views fade out
struct FadeStickyTransformer: StickyTransforming {
    fileprivate let axis: Axis
    fileprivate let scrollContainerEnd: CGFloat
    fileprivate let safeAreaInset: CGFloat
    fileprivate let frame: StickyFrame
    fileprivate let otherFrames: [StickyFrame]
    
    /// Creates sticky transformer for the fade out behavior
    /// - Parameters:
    ///   - axis: The axis of scroll
    ///   - scrollContainerEnd: The end position of the ``StickyScrollView``
    ///   - safeAreaInset: The safe area inset of the ``StickyScrollView``
    ///   - frame: The sticky frame that should be transformed
    ///   - otherFrames: Other sticky frames in the ``StickyScrollView``
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
        case .topLeading:
            switch axis {
            case .horizontal:
                return frame.frame.minX < stickingThreshold
            case .vertical:
                return frame.frame.minY < stickingThreshold
            }
        case .bottomTrailing:
            switch axis {
            case .horizontal:
                return frame.frame.maxX > stickingThreshold
            case .vertical:
                return frame.frame.maxY > stickingThreshold
            }
        }
    }
    
    /// If the view should use a custom zIndex
    /// Happens when another views begins to push this view off screen
    var shouldOverlay: Bool {
        guard let previousFrame else { return true }
        switch frame.edge {
        case .topLeading:
            switch axis {
            case .horizontal:
                return frame.frame.minX < previousFrame.frame.width - safeAreaInset
            case .vertical:
                return frame.frame.minY < previousFrame.frame.height - safeAreaInset
            }
        case .bottomTrailing:
            switch axis {
            case .horizontal:
                return frame.frame.maxX > scrollContainerEnd + safeAreaInset - previousFrame.frame.width
            case .vertical:
                return frame.frame.maxY > scrollContainerEnd + safeAreaInset - previousFrame.frame.height
            }
        }
    }
    
    /// The minimum/maximum value below/above which a view will stick
    var stickingThreshold: CGFloat {
        switch frame.edge {
        case .topLeading:
            return .zero - safeAreaInset
        case .bottomTrailing:
            return scrollContainerEnd + safeAreaInset
        }
    }
        
    /// The offset needed to keep the view visible
    fileprivate var offset: CGSize {
        // Do not offset if this view is not yet sticking
        guard isSticking else { return .zero }
        
        switch frame.edge {
        case .topLeading:
            switch axis {
            case .horizontal:
                // Offset so view is at the leading edge
                let offset = stickingThreshold - frame.frame.minX
                
                return CGSize(width: offset, height: .zero)
            case .vertical:
                // Offset so view is at the top edge
                let offset = stickingThreshold - frame.frame.minY

                return CGSize(width: .zero, height: offset)
            }
        case .bottomTrailing:
            switch axis {
            case .horizontal:
                // Offset so view is at the trailing edge
                let offset = stickingThreshold - frame.frame.maxX
                
                return CGSize(width: offset, height: .zero)
            case .vertical:
                // Offset so view is at the bottom edge
                let offset = stickingThreshold - frame.frame.maxY
                
                return CGSize(width: .zero, height: offset)
            }
        }
    }
    
    /// The frame that immediately precedes (topLeading) or follows (bottomTrailing) the main frame
    fileprivate var previousFrame: StickyFrame? {
        switch frame.edge {
        case .topLeading:
            switch axis {
            case .horizontal:
                // Find first frame to the left of this view
                return otherFrames.last(where: { value in
                    value.edge == frame.edge && value.frame.minX < frame.frame.minX
                })
            case .vertical:
                // Find first frame above this view
                return otherFrames.last(where: { value in
                    value.edge == frame.edge && value.frame.minY < frame.frame.minY
                })
            }
        case .bottomTrailing:
            switch axis {
            case .horizontal:
                // Find first frame to the right of this view
                return otherFrames.first(where: { value in
                    value.edge == frame.edge && value.frame.minX > frame.frame.minX
                })
            case .vertical:
                // Find first frame below this view
                return otherFrames.first(where: { value in
                    value.edge == frame.edge && value.frame.minY > frame.frame.minY
                })
            }
        }
    }
    
    /// The next frame that immediately follows (topLeading) or precedes (bottomTrailing) the main frame, if there is one
    fileprivate var nextStickingFrame: StickyFrame? {
        guard isSticking else { return nil }
        
        switch frame.edge {
        case .topLeading:
            switch axis {
            case .horizontal:
                // Find first frame to the right of this view that would collide
                return otherFrames.first(where: { value in
                    value.edge == frame.edge && value.frame.minX > frame.frame.minX
                        && value.frame.minX - stickingThreshold < frame.frame.width
                })
            case .vertical:
                // Find first frame below this view that would collide
                return otherFrames.first(where: { value in
                    value.edge == frame.edge && value.frame.minY > frame.frame.minY
                        && value.frame.minY - stickingThreshold < frame.frame.height
                })
            }
        case .bottomTrailing:
            switch axis {
            case .horizontal:
                // Find first frame to the left of this view that would collide
                return otherFrames.last(where: { value in
                    value.edge == frame.edge && value.frame.minX < frame.frame.minX
                        && stickingThreshold - value.frame.maxX < frame.frame.width
                })
            case .vertical:
                // Find first frame above this view that would collide
                return otherFrames.last(where: { value in
                    value.edge == frame.edge && value.frame.minY < frame.frame.minY
                        && stickingThreshold - value.frame.maxY < frame.frame.height
                })
            }
        }
    }
    
    /// The amount to fade the view
    /// Calculated based on how covered the view is by the next sticking view
    fileprivate var fadeAmount: CGFloat {
        guard let nextStickingFrame else { return .zero }
        
        let amount: CGFloat
        switch frame.edge {
        case .topLeading:
            switch axis {
            case .horizontal:
                amount = frame.frame.width - safeAreaInset - nextStickingFrame.frame.minX
            case .vertical:
                amount = frame.frame.height - safeAreaInset - nextStickingFrame.frame.minY
            }
        case .bottomTrailing:
            switch axis {
            case .horizontal:
                amount = nextStickingFrame.frame.maxX - scrollContainerEnd - safeAreaInset + frame.frame.width
            case .vertical:
                amount = nextStickingFrame.frame.maxY - scrollContainerEnd - safeAreaInset + frame.frame.height
            }
        }
        
        return max(.zero, amount)
    }
    
    /// The factor to scale the view by, driven by the fade amount
    fileprivate var scaleFactor: Double {
        return max(0, 1 - (fadeAmount / (frame.frame.height * 2)))
    }
    
    /// This offset is needed to keep the view anchored at the edge after the scaling is applied
    fileprivate var additionalOffset: CGSize {
        // Do not offset if this view is not yet sticking
        guard isSticking else { return .zero }
        
        switch frame.edge {
        case .topLeading:
            switch axis {
            case .horizontal:
                // Offset so view is at the leading edge
                let width = frame.frame.width
                let offset = (width - width * scaleFactor) / 2
                
                return CGSize(width: -offset, height: .zero)
            case .vertical:
                // Offset so view is at the top edge
                let height = frame.frame.height
                let offset = (height - height * scaleFactor) / 2

                return CGSize(width: .zero, height: -offset)
            }
        case .bottomTrailing:
            switch axis {
            case .horizontal:
                // Offset so view is at the trailing edge
                let width = frame.frame.width
                let offset = (width - width * scaleFactor) / 2
                
                return CGSize(width: offset, height: .zero)
            case .vertical:
                // Offset so view is at the bottom edge
                let height = frame.frame.height
                let offset = (height - height * scaleFactor) / 2
                
                return CGSize(width: .zero, height: offset)
            }
        }
    }
    
    /// The brightness of the view, driven by the fade amount
    fileprivate var brightness: Double {
        return fadeAmount / (frame.frame.height * 2)
    }
    
    /// The blur radius of the view, driven by the fade amount
    fileprivate var blurRadius: Double {
        return fadeAmount / (frame.frame.height * 2)
    }
    
    /// Transforms a view for the fade out behavior
    /// - Parameter content: The view to be transformed
    /// - Returns: The transformed view
    func stickyTransform<Content: View>(content: Content) -> any View {
        return content
            .scaleEffect(scaleFactor)
            .offset(offset)
            .offset(additionalOffset)
            .brightness(brightness)
            .blur(radius: blurRadius)
    }
}
