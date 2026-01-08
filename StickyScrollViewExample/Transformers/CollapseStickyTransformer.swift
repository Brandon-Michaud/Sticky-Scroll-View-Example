//
//  CollapseStickyTransformer.swift
//  StickyScrollView
//
//  Created by Brandon Michaud on 1/7/26.
//

import SwiftUI

/// A transformer that will make previous sticky views collapse
struct CollapseStickyTransformer: StickyTransforming {
    fileprivate let axis: Axis
    fileprivate let scrollContainerEnd: CGFloat
    fileprivate let safeAreaInset: CGFloat
    fileprivate let frame: StickyFrame
    fileprivate let otherFrames: [StickyFrame]
    
    /// Creates sticky transformer for the collapse behavior
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
        
        let offset: CGFloat
        switch frame.edge {
        case .topLeading:
            switch axis {
            case .horizontal:
                // Offset so view is at the leading edge
                offset = stickingThreshold - frame.frame.minX
            case .vertical:
                // Offset so view is at the top edge
                offset = stickingThreshold - frame.frame.minY
            }
        case .bottomTrailing:
            switch axis {
            case .horizontal:
                // Offset so view is at the trailing edge
                offset = stickingThreshold - frame.frame.maxX
            case .vertical:
                // Offset so view is at the bottom edge
                offset = stickingThreshold - frame.frame.maxY
            }
        }
        
        // Find the base offset that will not be scaled
        let nextStickingFramesSize = fadeAmount
        let baseOffset = offset - nextStickingFramesSize
        
        // Decrease the offset if we are topLeading, increae if we are bottomTrailing
        let scaleFactor: CGFloat
        switch frame.edge {
        case .topLeading:
            scaleFactor = 0.75
        case .bottomTrailing:
            scaleFactor = 1.25
        }
        
        // Scale the offset
        let scaledOffset = nextStickingFramesSize * scaleFactor
        let adjustedOffset = baseOffset + scaledOffset
        
        switch axis {
        case .horizontal:
            return CGSize(width: adjustedOffset, height: .zero)
        case .vertical:
            return CGSize(width: .zero, height: adjustedOffset)
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
    
    /// The next sticking frames that  follow (topLeading) or precede (bottomTrailing) the main frame, if there are any
    fileprivate var nextStickingFrames: [StickyFrame] {
        switch frame.edge {
        case .topLeading:
            switch axis {
            case .horizontal:
                return otherFrames.filter { value in
                    value.edge == frame.edge && value.frame.minX > frame.frame.minX
                        && value.frame.minX - stickingThreshold < frame.frame.width
                }.sorted(by: { $0.frame.minX < $1.frame.minX })
            case .vertical:
                return otherFrames.filter { value in
                    value.edge == frame.edge && value.frame.minY > frame.frame.minY
                        && value.frame.minY - stickingThreshold < frame.frame.height
                }.sorted(by: { $0.frame.minY < $1.frame.minY })
            }
        case .bottomTrailing:
            switch axis {
            case .horizontal:
                return otherFrames.filter { value in
                    value.edge == frame.edge && value.frame.minX < frame.frame.minX
                        && stickingThreshold - value.frame.maxX < frame.frame.width
                }.sorted(by: { $0.frame.minX > $1.frame.minX })
            case .vertical:
                return otherFrames.filter { value in
                    value.edge == frame.edge && value.frame.minY < frame.frame.minY
                        && stickingThreshold - value.frame.maxY < frame.frame.height
                }.sorted(by: { $0.frame.minY > $1.frame.minY })
            }
        }
    }
    
    /// The amount to fade the view
    /// Calculated based on how covered the view is by the next sticking view(s)
    fileprivate var fadeAmount: CGFloat {
        switch frame.edge {
        case .topLeading:
            switch axis {
            case .horizontal:
                return nextStickingFrames.reduce(into: 0) { result, element in
                    result += element.frame.width - max(0, element.frame.minX - stickingThreshold)
                }
            case .vertical:
                return nextStickingFrames.reduce(into: 0) { result, element in
                    result += element.frame.height - max(0, element.frame.minY - stickingThreshold)
                }
            }
        case .bottomTrailing:
            switch axis {
            case .horizontal:
                return nextStickingFrames.reduce(into: 0) { result, element in
                    result += element.frame.width - max(0, stickingThreshold - element.frame.maxX)
                }
            case .vertical:
                return nextStickingFrames.reduce(into: 0) { result, element in
                    result += element.frame.height - max(0, stickingThreshold - element.frame.maxY)
                }
            }
        }
    }
    
    /// The factor to scale the view by, driven by the fade amount
    fileprivate var scaleFactor: Double {
        return max(0, 1 - (fadeAmount / 700))
    }
    
    /// The brightness of the view, driven by the fade amount
    fileprivate var brightness: Double {
        return fadeAmount / 400
    }
    
    /// The blur radius of the view, driven by the fade amount
    fileprivate var blurRadius: Double {
        return fadeAmount / 50
    }
    
    /// Transforms a view for the collapse behavior
    /// - Parameter content: The view to be transformed
    /// - Returns: The transformed view
    func stickyTransform<Content: View>(content: Content) -> any View {
        return content
            .scaleEffect(scaleFactor)
            .offset(offset)
            .brightness(brightness)
            .blur(radius: blurRadius)
    }
}
