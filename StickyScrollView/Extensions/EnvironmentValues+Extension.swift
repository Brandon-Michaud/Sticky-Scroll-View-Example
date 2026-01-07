//
//  EnvironmentValues+Extension.swift
//  StickyScrollView
//
//  Created by Brandon Michaud on 1/4/26.
//

import SwiftUI

extension EnvironmentValues {
    /// Controls whether the ``Sticky`` view modifier can be applied
    @Entry var isStickable: Bool = false
    
    /// The sticky axis used by subviews in a ``StickyScrollView`` to determine their offset
    @Entry var stickyAxis: Axis = .vertical
    
    /// Describes how a ``StickyScrollView`` should handle situations where multiple subviews are sticking
    @Entry var stickyBehavior: StickyBehavior = .fadeOut
    
    /// The safe area edges which sticky subviews in a ``StickyScrollView`` can enter
    @Entry var stickyEdgesIgnoringSafeArea: [StickyEdge] = []
    
    /// A collection of sticky frames used for subviews in a ``StickyScrollView`` to determine their offset
    @Entry var stickyFrames: [Namespace.ID: StickyFrame] = [:]
    
    /// An optional ``StickyScrollViewCoordinator`` that subviews of a ``StickyScrollView`` can use to control the scroll position
    @Entry var stickyScrollCoordinator: StickyScrollCoordinator? = nil
}
