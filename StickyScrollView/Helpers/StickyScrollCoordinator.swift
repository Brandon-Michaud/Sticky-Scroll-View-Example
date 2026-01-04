//
//  StickyScrollCoordinator.swift
//  StickyScrollView
//
//  Created by Brandon Michaud on 1/4/26.
//

import SwiftUI

/// An object that can control the scroll position of a ``StickyScrollView``
@Observable final class StickyScrollCoordinator {
    /// The coordinate space name used by the sticky scroll view
    let coordinateSpace: String
    
    /// The sticky scroll view scroll position
    var scrollPosition: ScrollPosition
    
    /// The sticky scroll view content offset
    var scrollContentOffset: CGPoint
    
    /// The sticky scroll view content size
    var scrollContentSize: CGSize
    
    /// The sticky scroll view content insets
    var scrollContentInsets: EdgeInsets
    
    /// The sticky scroll view container size
    var scrollContainerSize: CGSize

    /// Makes a ``StickyScrollCoordinator`` with an initial position
    /// - Parameters:
    ///   - coordinateSpace: The name of the coordinate space for the ``StickyScrollView``
    ///   - scrollPosition: Initial ``ScrollPosition`` of the ``StickyScrollView``
    ///   - scrollContentOffset: Content offset of the ``StickyScrollView``
    ///   - scrollContentSize: Content size of the ``StickyScrollView``
    ///   - scrollContentInsets: Content insets of the ``StickyScrollView``
    ///   - scrollContainerSize: Container size of the ``StickyScrollView``
    init(
        coordinateSpace: String = "stickyCoordinateSpace",
        scrollPosition: ScrollPosition = ScrollPosition(edge: .top),
        scrollContentOffset: CGPoint = .zero,
        scrollContentSize: CGSize = .zero,
        scrollContentInsets: EdgeInsets = .init(),
        scrollContainerSize: CGSize = .zero
    ) {
        self.coordinateSpace = coordinateSpace
        self.scrollPosition = scrollPosition
        self.scrollContentOffset = scrollContentOffset
        self.scrollContentSize = scrollContentSize
        self.scrollContentInsets = scrollContentInsets
        self.scrollContainerSize = scrollContainerSize
    }
}
