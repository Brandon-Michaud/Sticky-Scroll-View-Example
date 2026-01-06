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
    private let onTap: (() -> Void)?
    private let onStickChange: ((Bool) -> Void)?
    
    /// Creates a view modifier to make content stick to the starting edge
    /// - Parameters:
    ///   - edge: The edge of the ``StickyScrollView`` the view should stick to
    ///   - isTappable: Whether or not tapping the sticky content scrolls to it
    ///   - onTap: Optional closure to execute when the view is tapped
    ///   - onStickChange: Optional closure to execute when the view sticks or unsticks
    public init(
        edge: StickyEdge = .topLeading,
        isTappable: Bool = false,
        onTap: (() -> Void)? = nil,
        onStickChange: ((Bool) -> Void)? = nil
    ) {
        self.edge = edge
        self.isTappable = isTappable
        self.onTap = onTap
        self.onStickChange = onStickChange
    }
    
    /// The transformer to use for this view
    private var transformer: StickyTransforming {
        guard let scrollContainerEnd else { return IdentityStickyTransformer() }
        
        var stickyFrames = self.stickyFrames
        stickyFrames.removeValue(forKey: id)
        let otherFrames: [StickyFrame] = Array(stickyFrames.values)
        
        switch stickyBehavior {
        case .replace:
            return ReplaceStickyTransformer(
                axis: stickyAxis,
                scrollContainerEnd: scrollContainerEnd,
                safeAreaInset: safeAreaInset,
                frame: StickyFrame(frame: frame, edge: edge),
                otherFrames: otherFrames
            )
        case .fadeOut:
            return FadeOutStickyTransformer(
                axis: stickyAxis,
                scrollContainerEnd: scrollContainerEnd,
                safeAreaInset: safeAreaInset,
                frame: StickyFrame(frame: frame, edge: edge),
                otherFrames: otherFrames
            )
        case .stack:
            return StackStickyTransformer(
                axis: stickyAxis,
                scrollContainerEnd: scrollContainerEnd,
                safeAreaInset: safeAreaInset,
                frame: StickyFrame(frame: frame, edge: edge),
                otherFrames: otherFrames
            )
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
        case .topLeading:
            switch stickyAxis {
            case .horizontal:
                return safeAreaInsets.leading
            case .vertical:
                return safeAreaInsets.top
            }
        case .bottomTrailing:
            switch stickyAxis {
            case .horizontal:
                return safeAreaInsets.trailing
            case .vertical:
                return safeAreaInsets.bottom
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
            let startingAnchor = frame.minX + scrollContentOffset.x - transformer.stickingThreshold + scrollContentInsets.leading
            let anchorOffset = edge == .bottomTrailing ? frame.width : .zero
            return CGPoint(x: startingAnchor + anchorOffset, y: .zero)
        case .vertical:
            let startingAnchor = frame.minY + scrollContentOffset.y - transformer.stickingThreshold + scrollContentInsets.top
            let anchorOffset = edge == .bottomTrailing ? frame.height : .zero
            return CGPoint(x: .zero, y: startingAnchor + anchorOffset)
        }
    }
    
    /// The zIndex to render the view at
    private var zIndex: Double {
        guard let contentSize = stickyScrollCoordinator?.scrollContentSize else { return .infinity }
        
        let zIndex: Double
        switch edge {
        case .topLeading:
            // Earlier views should be rendered lower
            switch stickyAxis {
            case .horizontal:
                zIndex = contentSize.width + frame.minX
            case .vertical:
                zIndex = contentSize.height + frame.minY
            }
        case .bottomTrailing:
            // Later views should be rendered lower
            switch stickyAxis {
            case .horizontal:
                zIndex = contentSize.width - frame.maxX
            case .vertical:
                zIndex = contentSize.height - frame.maxY
            }
        }
        return transformer.shouldOverlay ? zIndex : 0
    }

    public func body(content: Content) -> some View {
        if isStickable, let coordinateSpace = stickyScrollCoordinator?.coordinateSpace {
            content
                .id(id)
                .zIndex(zIndex)  // If the view is sticking, it should appear above all others
                .stickyTransform(using: transformer)
                .overlay(GeometryReader { geometry in
                    let frame = geometry.frame(in: .named(coordinateSpace))
                    Color.clear
                        .onAppear { self.frame = frame }
                        .onChange(of: frame) { self.frame = frame }
                        .preference(key: StickyFramePreference.self, value: [id: StickyFrame(frame: self.frame, edge: edge)])
                })
                .onTapGesture {
                    if isTappable {
                        onTap?()
                        
                        withAnimation(.easeInOut(duration: 0.25)) {
                            stickyScrollCoordinator?.scrollPosition.scrollTo(point: scrollPosition)
                        }
                    }
                }
                .onChange(of: transformer.isSticking) {
                    onStickChange?(transformer.isSticking)
                }
        } else {
            content
        }
    }
}
