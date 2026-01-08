//
//  StackStickyTransformer.swift
//  StickyScrollView
//
//  Created by Brandon Michaud on 1/5/26.
//

import SwiftUI

/// A transformer that will stack previous sticky views
struct StackStickyTransformer: StickyTransforming {
    fileprivate let axis: Axis
    fileprivate let scrollContainerEnd: CGFloat
    fileprivate let safeAreaInset: CGFloat
    fileprivate let frame: StickyFrame
    fileprivate let otherFrames: [StickyFrame]
    
    /// Creates sticky transformer for the stack behavior
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
    var shouldOverlay: Bool {
        return isSticking
    }
    
    /// The minimum/maximum value below/above which a view will stick
    var stickingThreshold: CGFloat {
        switch frame.edge {
        case .topLeading:
            switch axis {
            case .horizontal:
                // Find cumulative width of other sticky frames to the left of this one
                let otherSticking = otherFrames.filter { value in
                    value.edge == frame.edge && value.frame.minX <= frame.frame.minX
                }
                return -safeAreaInset + otherSticking.reduce(into: 0) { (result, element) in
                    result += element.frame.width
                }
            case .vertical:
                // Find cumulative height of other sticky frames above this one
                let otherSticking = otherFrames.filter { value in
                    value.edge == frame.edge && value.frame.minY <= frame.frame.minY
                }
                return -safeAreaInset + otherSticking.reduce(into: 0) { (result, element) in
                    result += element.frame.height
                }
            }
        case .bottomTrailing:
            switch axis {
            case .horizontal:
                // Find cumulative width of other sticky frames to the right of this one
                let otherSticking = otherFrames.filter { value in
                    value.edge == frame.edge && value.frame.maxX >= frame.frame.maxX
                }
                return scrollContainerEnd + safeAreaInset - otherSticking.reduce(into: 0) { (result, element) in
                    result += element.frame.width
                }
            case .vertical:
                // Find cumulative height of other sticky frames below this one
                let otherSticking = otherFrames.filter { value in
                    value.edge == frame.edge && value.frame.maxY >= frame.frame.maxY
                }
                return scrollContainerEnd + safeAreaInset  - otherSticking.reduce(into: 0) { (result, element) in
                    result += element.frame.height
                }
            }
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
                // Offset view to the leading edge of the stack
                return CGSize(width: -frame.frame.minX + stickingThreshold, height: .zero)
            case .vertical:
                // Offset view to the top edge of the stack
                return CGSize(width: .zero, height: -frame.frame.minY + stickingThreshold)
            }
        case .bottomTrailing:
            switch axis {
            case .horizontal:
                // Offset view to the trailing edge of the stack
                return CGSize(width: -frame.frame.maxX + stickingThreshold, height: .zero)
            case .vertical:
                // Offset view to the bottom edge of the stack
                return CGSize(width: .zero, height: -frame.frame.maxY + stickingThreshold)
            }
        }
    }
    
    /// Transforms a view for the stack behavior
    /// - Parameter content: The view to be transformed
    /// - Returns: The transformed view
    func stickyTransform<Content>(content: Content) -> any View where Content : View {
        content
            .offset(offset)
    }
}
