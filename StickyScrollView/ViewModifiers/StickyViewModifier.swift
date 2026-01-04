//
//  StickyViewModifier.swift
//  StickyScrollView
//
//  Created by Brandon Michaud on 1/4/26.
//

import SwiftUI

/// A view modifier to make some view inside of a ``StickyScrollView`` sticky
public struct StickyViewModifier: ViewModifier {
    @Namespace private var id
    
    // Collect offset rendering information
    @Environment(\.isStickable) fileprivate var isStickable
    @Environment(\.stickyAxis) fileprivate var stickyAxis
    @Environment(\.stickyBehavior) fileprivate var stickyBehavior
    @Environment(\.stickyEdgesIgnoringSafeArea) fileprivate var stickyEdgesIgnoringSafeArea
    @Environment(\.stickyFrames) fileprivate var stickyFrames
    @Environment(\.stickyScrollCoordinator) fileprivate var stickyScrollCoordinator
    
    // Keep track of the view's frame
    @State private var frame: CGRect = .zero
    
    private let edge: StickyEdge
    private let isTappable: Bool
    
    /// Creates a view modifier to make content stick to the starting edge
    /// - Parameters:
    ///   - edge: The edge of the ``StickyScrollView`` the view should stick to
    ///   - isTappable: Whether or not tapping the sticky content scrolls to it
    public init(edge: StickyEdge = .starting, isTappable: Bool = false) {
        self.edge = edge
        self.isTappable = isTappable
    }
    
    /// If the view should be sticking
    private var isSticking: Bool {
        switch edge {
        case .starting:
            switch stickyAxis {
            case .horizontal:
                return frame.minX < stickingThreshold
            case .vertical:
                return frame.minY < stickingThreshold
            }
        case .ending:
            switch stickyAxis {
            case .horizontal:
                return frame.maxX > stickingThreshold
            case .vertical:
                return frame.maxY > stickingThreshold
            }
        }
    }
    
    /// The end position of the scroll view
    private var scrollContainerEnd: CGFloat? {
        guard let stickyScrollCoordinator else { return nil }
        switch stickyAxis {
        case .horizontal:
            return stickyScrollCoordinator.scrollContainerSize.width
        case .vertical:
            return stickyScrollCoordinator.scrollContainerSize.height
        }
    }
    
    /// Gets the correct safe area inset for view
    private var safeAreaInset: CGFloat {
        guard let safeAreaInsets = stickyScrollCoordinator?.scrollContentInsets else { return .zero }
        guard stickyEdgesIgnoringSafeArea.contains(edge) else { return .zero }
        switch edge {
        case .starting:
            switch stickyAxis {
            case .horizontal:
                return safeAreaInsets.leading
            case .vertical:
                return safeAreaInsets.top
            }
        case .ending:
            switch stickyAxis {
            case .horizontal:
                return safeAreaInsets.trailing
            case .vertical:
                return safeAreaInsets.bottom
            }
        }
    }
    
    /// The minimum/maximum value below/above which a view will stick
    private var stickingThreshold: CGFloat {
        // If we do not have the scrollContainerBounds we cannot compute threshold and the view should not stick
        guard let scrollContainerEnd else {
            switch edge {
            case .starting:
                return -.infinity
            case .ending:
                return .infinity
            }
        }
        
        // If we are replacing views, the thresholds are the edges of the scroll view
        guard stickyBehavior != .replace else {
            switch edge {
            case .starting:
                return .zero - safeAreaInset
            case .ending:
                return scrollContainerEnd + safeAreaInset
            }
        }
        
        switch edge {
        case .starting:
            switch stickyAxis {
            case .horizontal:
                // Find cumulative width of other sticky frames to the left of this one
                let otherSticking = stickyFrames.filter { (key, value) in
                    key != id && value.edge == edge && value.frame.minX <= frame.minX
                }
                return -safeAreaInset + otherSticking.reduce(into: 0) { (result, element) in
                    result += element.value.frame.width
                }
            case .vertical:
                // Find cumulative height of other sticky frames above this one
                let otherSticking = stickyFrames.filter { (key, value) in
                    key != id && value.edge == edge && value.frame.minY <= frame.minY
                }
                return -safeAreaInset + otherSticking.reduce(into: 0) { (result, element) in
                    result += element.value.frame.height
                }
            }
        case .ending:
            switch stickyAxis {
            case .horizontal:
                // Find cumulative width of other sticky frames to the right of this one
                let otherSticking = stickyFrames.filter { (key, value) in
                    key != id && value.edge == edge && value.frame.maxX >= frame.maxX
                }
                return scrollContainerEnd + safeAreaInset - otherSticking.reduce(into: 0) { (result, element) in
                    result += element.value.frame.width
                }
            case .vertical:
                // Find cumulative height of other sticky frames below this one
                let otherSticking = stickyFrames.filter { (key, value) in
                    key != id && value.edge == edge && value.frame.maxY >= frame.maxY
                }
                return scrollContainerEnd + safeAreaInset  - otherSticking.reduce(into: 0) { (result, element) in
                    result += element.value.frame.height
                }
            }
        }
    }
    
    /// The offset needed to keep the view visible
    private var offset: CGSize {
        // Do not offset if this view is not yet sticking
        guard isSticking else { return CGSize.zero }
        
        switch stickyBehavior {
        case .replace:
            switch edge {
            case .starting:
                switch stickyAxis {
                case .horizontal:
                    // Offset so view is at the leading edge
                    var offset = stickingThreshold - frame.minX
                    
                    // Find first frame to the right of this view that would collide and
                    // calculate offset to prevent that
                    if let other = stickyFrames.first(where: { (key, value) in
                        key != id && value.edge == edge && value.frame.minX > frame.minX
                            && value.frame.minX - stickingThreshold < frame.width
                    }) {
                        offset -= frame.width + stickingThreshold - other.value.frame.minX
                    }
                    
                    return CGSize(width: offset, height: .zero)
                case .vertical:
                    // Offset so view is at the top edge
                    var offset = stickingThreshold - frame.minY
                    
                    // Find first frame below this view that would collide and
                    // calculate offset to prevent that
                    if let other = stickyFrames.first(where: { (key, value) in
                        key != id && value.edge == edge && value.frame.minY > frame.minY
                            && value.frame.minY - stickingThreshold < frame.height
                    }) {
                        offset -= frame.height + stickingThreshold - other.value.frame.minY
                    }
                    
                    return CGSize(width: .zero, height: offset)
                }
            case .ending:
                switch stickyAxis {
                case .horizontal:
                    // Offset so view is at the trailing edge
                    var offset = stickingThreshold - frame.maxX
                    
                    // Find first frame to the left of this view that would collide and
                    // calculate offset to prevent that
                    // TODO: There is a bug here because every single sticking frame with find the same "other"
                    // TODO: We really need the "other" frame with the maximum minX
                    if let other = stickyFrames.first(where: { (key, value) in
                        key != id && value.edge == edge && value.frame.minX < frame.minX
                            && stickingThreshold - value.frame.maxX < frame.width
                    }) {
                        offset += frame.width - stickingThreshold + other.value.frame.maxX
                    }
                    
                    return CGSize(width: offset, height: .zero)
                case .vertical:
                    // Offset so view is at the bottom edge
                    var offset = stickingThreshold - frame.maxY
                    
                    // Find first frame above this view that would collide and
                    // calculate offset to prevent that
                    // TODO: There is a bug here because every single sticking frame with find the same "other"
                    // TODO: We really need the "other" frame with the maximum minY
                    if let other = stickyFrames.first(where: { (key, value) in
                        key != id && value.edge == edge && value.frame.minY < frame.minY
                            && stickingThreshold - value.frame.maxY < frame.height
                    }) {
                        offset += frame.height - stickingThreshold + other.value.frame.maxY
                    }
                    
                    return CGSize(width: .zero, height: offset)
                }
            }
        case .stack:
            switch edge {
            case .starting:
                switch stickyAxis {
                case .horizontal:
                    // Offset view to the leading/trailing edge of the stack
                    return CGSize(width: -frame.minX + stickingThreshold, height: .zero)
                case .vertical:
                    // Offset view to the top/bottom edge of the stack
                    return CGSize(width: .zero, height: -frame.minY + stickingThreshold)
                }
            case .ending:
                switch stickyAxis {
                case .horizontal:
                    // Offset view to the leading/trailing edge of the stack
                    return CGSize(width: -frame.maxX + stickingThreshold, height: .zero)
                case .vertical:
                    // Offset view to the top/bottom edge of the stack
                    return CGSize(width: .zero, height: -frame.maxY + stickingThreshold)
                }
            }
        }
    }
    
    /// The position to scroll to when the view is tapped
    private var scrollPosition: CGPoint {
        guard
            let scrollContentOffset = stickyScrollCoordinator?.scrollContentOffset,
            let scrollContentInsets = stickyScrollCoordinator?.scrollContentInsets
        else {
            return .zero
        }
        
        switch stickyAxis {
        case .horizontal:
            let startingAnchor = frame.minX + scrollContentOffset.x - stickingThreshold + scrollContentInsets.leading
            let anchorOffset = edge == .ending ? frame.width : .zero
            return CGPoint(x: startingAnchor + anchorOffset, y: .zero)
        case .vertical:
            let startingAnchor = frame.minY + scrollContentOffset.y - stickingThreshold + scrollContentInsets.top
            let anchorOffset = edge == .ending ? frame.height : .zero
            return CGPoint(x: .zero, y: startingAnchor + anchorOffset)
        }
    }
    
    /// The zIndex to render the view at
    private var zIndex: Double {
        let contentSize = stickyScrollCoordinator?.scrollContentSize.height ?? .infinity
        let zIndex: Double
        switch edge {
        case .starting:
            // Earlier views should be rendered below
            zIndex = contentSize + frame.minY
        case .ending:
            // Later views should be rendered above
            zIndex = contentSize - frame.maxY
        }
        return isSticking ? zIndex : 0
    }

    public func body(content: Content) -> some View {
        if isStickable, let coordinateSpace = stickyScrollCoordinator?.coordinateSpace {
            content
                .id(id)
                .offset(offset)
                .zIndex(zIndex)  // If the view is sticking, it should appear above all others
                .overlay(GeometryReader { geometry in
                    let frame = geometry.frame(in: .named(coordinateSpace))
                    Color.clear
                        .onAppear { self.frame = frame }
                        .onChange(of: frame) { self.frame = frame }
                        .preference(key: StickyFramePreference.self, value: [id: StickyFrame(frame: self.frame, edge: edge)])
                })
                .onTapGesture {
                    if isTappable {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            stickyScrollCoordinator?.scrollPosition.scrollTo(point: scrollPosition)
                        }
                    }
                }
        } else {
            content
        }
    }
}
