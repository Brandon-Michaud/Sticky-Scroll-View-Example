//
//  IdentityStickyTransformer.swift
//  StickyScrollView
//
//  Created by Brandon Michaud on 1/5/26.
//

import SwiftUI

/// A transformer that does not apply any changes
struct IdentityStickyTransformer: StickyTransforming {
    /// Views should never stick
    var isSticking: Bool { false }
    
    /// Views should never overlay
    var shouldOverlay: Bool { false }
    
    /// Views should never meet the sticking threshold
    var stickingThreshold: CGFloat { .infinity }
    
    /// Transforms a view for the identity behavior
    /// - Parameter content: The view to be transformed
    /// - Returns: The transformed view
    func stickyTransform<Content: View>(content: Content) -> any View {
        content
    }
}
