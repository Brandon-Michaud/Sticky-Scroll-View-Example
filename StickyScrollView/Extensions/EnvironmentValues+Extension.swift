//
//  EnvironmentValues+Extension.swift
//  StickyScrollView
//
//  Created by Brandon Michaud on 1/4/26.
//

import SwiftUI

extension EnvironmentValues {
    /// Controls whether the ``Sticky`` view modifier can be applied
    var isStickable: Stickable.Value {
        get { self[Stickable.self] }
        set { self[Stickable.self] = newValue }
    }
    
    /// The sticky axis used by subviews in a ``StickyScrollView`` to determine their offset
    var stickyAxis: StickyAxis.Value {
        get { self[StickyAxis.self] }
        set { self[StickyAxis.self] = newValue }
    }
    
    /// Describes how a ``StickyScrollView`` should handle situations where multiple subviews are sticking
    var stickyBehavior: StickyBehaviorKey.Value {
        get { self[StickyBehaviorKey.self] }
        set { self[StickyBehaviorKey.self] = newValue }
    }
    
    /// The safe area edges which sticky subviews in a ``StickyScrollView`` can enter
    var stickyEdgesIgnoringSafeArea: StickyEdgesIgnoringSafeArea.Value {
        get { self[StickyEdgesIgnoringSafeArea.self] }
        set { self[StickyEdgesIgnoringSafeArea.self] = newValue }
    }
    
    /// A collection of sticky frames used for subviews in a ``StickyScrollView`` to determine their offset
    var stickyFrames: StickyFrames.Value {
        get { self[StickyFrames.self] }
        set { self[StickyFrames.self] = newValue }
    }
    
    /// An optional ``StickyScrollViewCoordinator`` that subviews of a ``StickyScrollView`` can use to control the scroll position
    var stickyScrollCoordinator: StickyScrollCoordinatorKey.Value {
        get { self[StickyScrollCoordinatorKey.self] }
        set { self[StickyScrollCoordinatorKey   .self] = newValue }
    }
}
