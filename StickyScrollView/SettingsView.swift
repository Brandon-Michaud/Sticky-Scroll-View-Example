//
//  SettingsView.swift
//  StickyScrollView
//
//  Created by Brandon Michaud on 1/3/26.
//

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
                    
                    HStack {
                        Text("Headers")
                            .font(.headline)
                        
                        Spacer()
                        
                        Picker("Headers", selection: $viewModel.numHeaders) {
                            ForEach(0...20, id: \.self) { num in
                                Text("\(num)")
                                    .tag(num)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                    
                    HStack {
                        Text("Footers")
                            .font(.headline)
                        
                        Spacer()
                        
                        Picker("Footers", selection: $viewModel.numFooters) {
                            ForEach(0...20, id: \.self) { num in
                                Text("\(num)")
                                    .tag(num)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                    
                    Toggle("Is Tappable", isOn: $viewModel.isTappable)
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
