//
//  PremiumView.swift
//  Waiky
//
//  Created by Elnur Imamaliyev on 01.08.2026.
//

import SwiftUI

struct PremiumView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()
                
                // Icon
                Image(systemName: "star.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.yellow)
                    .symbolEffect(.bounce, value: true)
                
                // Title
                VStack(spacing: 12) {
                    Text("Waiky Premium")
                        .font(.largeTitle)
                        .bold()
                    
                    Text("You're currently on the free plan")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                // Features
                VStack(alignment: .leading, spacing: 16) {
                    FeatureRow(
                        icon: "chart.line.uptrend.xyaxis",
                        title: "Advanced Trends",
                        description: "Track your wellness over weeks and months"
                    )
                    
                    FeatureRow(
                        icon: "sparkles.rectangle.stack",
                        title: "Unlimited AI Chat",
                        description: "Talk to your wellness coach anytime"
                    )
                    
                    FeatureRow(
                        icon: "checklist",
                        title: "Custom Habits",
                        description: "Create and track personalized habits"
                    )
                    
                    FeatureRow(
                        icon: "bell.badge",
                        title: "Smart Reminders",
                        description: "Get nudged at the perfect time"
                    )
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(16)
                
                Spacer()
                
                // Pricing
                VStack(spacing: 8) {
                    Text("€4.99")
                        .font(.largeTitle)
                        .bold()
                    
                    Text("per month")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                // CTA Button (mock only)
                Button {
                    // TODO: Integrate StoreKit for real purchases
                    print("Upgrade tapped - no real payment flow yet")
                } label: {
                    Text("Coming Soon")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.5))
                        .cornerRadius(12)
                }
                .disabled(true)
                
                Text("Payment integration coming soon")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.blue)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
    }
}

#Preview {
    PremiumView()
}
