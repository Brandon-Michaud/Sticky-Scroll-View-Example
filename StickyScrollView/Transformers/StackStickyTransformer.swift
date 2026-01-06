//
//  StackStickyTransformer.swift
//  StickyScrollView
//
//  Created by Brandon Michaud on 1/5/26.
//

import SwiftUI

/// A transformer that will stack previous sticky views
struct StackStickyTransformer: StickyTransforming {
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
        case .ending:
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
    var offset: CGSize {
        // Do not offset if this view is not yet sticking
        guard isSticking else { return CGSize.zero }
        
        switch frame.edge {
        case .starting:
            switch axis {
            case .horizontal:
                // Offset view to the leading/trailing edge of the stack
                return CGSize(width: -frame.frame.minX + stickingThreshold, height: .zero)
            case .vertical:
                // Offset view to the top/bottom edge of the stack
                return CGSize(width: .zero, height: -frame.frame.minY + stickingThreshold)
            }
        case .ending:
            switch axis {
            case .horizontal:
                // Offset view to the leading/trailing edge of the stack
                return CGSize(width: -frame.frame.maxX + stickingThreshold, height: .zero)
            case .vertical:
                // Offset view to the top/bottom edge of the stack
                return CGSize(width: .zero, height: -frame.frame.maxY + stickingThreshold)
            }
        }
    }
    
    func stickyTransform<Content>(content: Content) -> any View where Content : View {
        content
            .offset(offset)
    }
}
