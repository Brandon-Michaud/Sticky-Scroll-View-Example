//
//  StickyEnvironmentKeys.swift
//  StickyScrollView
//
//  Created by Brandon Michaud on 1/4/26.
//

import SwiftUI

/// Controls whether the ``Sticky`` view modifier can be applied
enum Stickable: EnvironmentKey {
    static var defaultValue: Bool = false
}

/// The sticky axis used by subviews in a ``StickyScrollView`` to determine their offset
enum StickyAxis: EnvironmentKey {
    static var defaultValue: Axis = .vertical
}

/// The ``StickyBehavior`` used by subviews in a ``StickyScrollView`` to determine their offset
enum StickyBehaviorKey: EnvironmentKey {
    static var defaultValue: StickyBehavior = .stack
}

/// The ``StickyEdge``s that can enter the safe area of a ``StickyScrollView``
enum StickyEdgesIgnoringSafeArea: EnvironmentKey {
    static var defaultValue: [StickyEdge] = []
}

/// A collection of sticky frames used for subviews in a ``StickyScrollView`` to determine their offset
enum StickyFrames: EnvironmentKey {
    static var defaultValue: [Namespace.ID: StickyFrame] = [:]
}

/// A ``StickyScrollCoordinator`` that subviews of a ``StickyScrollView`` can use to control the scroll position
enum StickyScrollCoordinatorKey: EnvironmentKey {
    static var defaultValue: StickyScrollCoordinator? = nil
}
