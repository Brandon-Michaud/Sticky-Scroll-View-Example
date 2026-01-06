//
//  StickyTransforming.swift
//  StickyScrollView
//
//  Created by Brandon Michaud on 1/5/26.
//

import SwiftUI

/// Any instance that describes how and when to transform a sticky view in a ``StickyScrollView``
protocol StickyTransforming {
    var isSticking: Bool { get }
    var stickingThreshold: CGFloat { get }
    func stickyTransform<Content: View>(content: Content) -> any View
}
