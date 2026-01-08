//
//  StickyFrame.swift
//  StickyScrollView
//
//  Created by Brandon Michaud on 1/4/26.
//

import SwiftUI

/// Data representation of a sticky frame and the edge it sticks to
struct StickyFrame: Equatable {
    let frame: CGRect
    let edge: StickyEdge
}
