//
//  StickyPreferenceKeys.swift
//  StickyScrollView
//
//  Created by Brandon Michaud on 1/4/26.
//

import SwiftUI

/// A preference used by subviews to communicate their frames to their ``StickyScrollView`` superview
enum StickyFramePreference: PreferenceKey {
    static var defaultValue: [Namespace.ID: StickyFrame] = [:]

    static func reduce(value: inout Value, nextValue: () -> Value) {
        value.merge(nextValue()) { $1 }
    }
}
