//
//  StickyTransforming.swift
//  StickyScrollView
//
//  Created by Brandon Michaud on 1/5/26.
//

import SwiftUI

/// Any instance that describes how and when to transform a sticky view in a ``StickyScrollView``
protocol StickyTransforming {
    /// If the view is sticking to the edge
    var isSticking: Bool { get }
    
    /// If the view should use a custom zIndex
    var shouldOverlay: Bool { get }
    
    /// The threshold for sticking to an edge
    var stickingThreshold: CGFloat { get }
    
    /// Transforms a view for the desired sticking behavior
    /// - Parameter content: The view to be transformed
    /// - Returns: The transformed view
    func stickyTransform<Content: View>(content: Content) -> any View
}
