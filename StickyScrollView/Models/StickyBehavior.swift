//
//  StickyBehavior.swift
//  StickyScrollView
//
//  Created by Brandon Michaud on 1/4/26.
//

/// Describes how a ``StickyScrollView`` should handle situations where multiple subviews are sticking
public enum StickyBehavior: String, CaseIterable {
    /// Any sticky view that reaches the ending edge of an already sticking view
    /// (or the starting edge of the scroll view if no views are sticking)
    /// will replace the already sticking view if there is one
    case replace
    
    /// Any sticky view that reaches the ending edge of an already sticking view
    /// (or the starting edge of the scroll view if no views are sticking)
    /// will overlay the already sticking view if there is one and the already sticking view will fade out
    case fade
    
    /// Any sticky view that reaches the ending edge of already sticking views
    /// (or the starting edge of the scroll view if no views are sticking)
    /// will append to the already sticking views
    case stack
    
    /// Any sticky view that reaches the ending edge of an already sticking view
    /// (or the starting edge of the scroll view if no views are sticking)
    /// will overlay the already sticking views if there are any and the already sticking views will collapse
    case collapse
}
