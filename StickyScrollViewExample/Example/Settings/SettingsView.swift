//
//  SettingsView.swift
//  StickyScrollView
//
//  Created by Brandon Michaud on 1/3/26.
//

import StickyScrollView
import SwiftUI

struct SettingsView: View {
    @Binding var viewModel: SettingsViewModel
    
    var body: some View {
        StickyScrollView {
            VStack(spacing: 20) {
                Text("Settings")
                    .font(.title2)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.ultraThinMaterial)
                    .sticky()
                
                VStack(spacing: 20) {
                    Toggle("Should Stick", isOn: $viewModel.shouldStick)
                        .font(.headline)
                    
                    VStack(alignment: .leading) {
                        Text("Scroll Axis")
                            .font(.headline)
                        
                        Picker("Scroll Axis", selection: $viewModel.scrollAxis) {
                            ForEach(Array(Axis.allCases), id: \.self) { axis in
                                Text(axis.description.capitalized)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Sticky Behavior")
                            .font(.headline)
                        
                        Picker("Sticky Behavior", selection: $viewModel.stickyBehavior) {
                            ForEach(Array(StickyBehavior.allCases), id: \.self) { behavior in
                                Text(behavior.rawValue.capitalized)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Headers: \(Int(viewModel.numHeaders))")
                            .font(.headline)
                        
                        Slider(value: $viewModel.numHeaders, in: 0...20, step: 1)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Footers: \(Int(viewModel.numFooters))")
                            .font(.headline)
                        
                        Slider(value: $viewModel.numFooters, in: 0...20, step: 1)
                    }
                    
                    Toggle("Is Tappable", isOn: $viewModel.isTappable)
                        .font(.headline)
                    
                    Toggle("Grow On Tap", isOn: $viewModel.growOnTap)
                        .font(.headline)
                    
                    Toggle("Invert On Stick", isOn: $viewModel.invertOnStick)
                        .font(.headline)
                    
                    Toggle("Ignore Starting Safe Area", isOn: $viewModel.ignoreStartingSafeArea)
                        .font(.headline)
                    
                    Toggle("Ignore Ending Safe Area", isOn: $viewModel.ignoreEndingSafeArea)
                        .font(.headline)
                }
                .padding([.horizontal, .bottom])
                
                Spacer()
            }
        }
        .scrollBounceBehavior(.basedOnSize)
        .scrollIndicators(.hidden)
    }
}
