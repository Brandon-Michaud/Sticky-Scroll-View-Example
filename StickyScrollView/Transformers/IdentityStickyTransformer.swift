//
//  IdentityStickyTransformer.swift
//  StickyScrollView
//
//  Created by Brandon Michaud on 1/5/26.
//

import SwiftUI

/// A transformer that does not apply any changes
struct IdentityStickyTransformer: StickyTransforming {
    var isSticking: Bool { false }
    var stickingThreshold: CGFloat { .infinity }
    
    func stickyTransform<Content: View>(content: Content) -> any View {
        content
    }
}
