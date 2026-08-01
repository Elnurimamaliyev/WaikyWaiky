//
//  OnboardingView.swift
//  Waiky
//
//  Created by Elnur Imamaliyev on 01.08.2026.
//

import SwiftUI

struct OnboardingView: View {
    @State private var step: Int = 0
    @State private var age: String = ""
    @State private var name: String = ""
    @State private var struggle: String = ""
    
    var onComplete: () -> Void
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Step indicator
            HStack(spacing: 8) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(index <= step ? Color.blue : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.bottom, 20)
            
            // Step content
            switch step {
            case 0:
                ageStep
            case 1:
                nameStep
            case 2:
                struggleStep
            default:
                EmptyView()
            }
            
            Spacer()
            
            // Navigation buttons
            if step < 2 {
                Button("Next") {
                    withAnimation {
                        step += 1
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(!canProceed)
            } else {
                Button("Get Started") {
                    saveUserData()
                    onComplete()
                }
                .buttonStyle(.borderedProminent)
                .disabled(struggle.isEmpty)
            }
        }
        .padding()
    }
    
    private var ageStep: some View {
        VStack(spacing: 20) {
            Text("How old are you?")
                .font(.largeTitle)
                .bold()
            
            TextField("Your age", text: $age)
                .keyboardType(.numberPad)
                .textFieldStyle(.roundedBorder)
                .multilineTextAlignment(.center)
                .font(.title)
                .frame(maxWidth: 200)
        }
    }
    
    private var nameStep: some View {
        VStack(spacing: 20) {
            Text("What's your name?")
                .font(.largeTitle)
                .bold()
            
            TextField("Your name", text: $name)
                .textFieldStyle(.roundedBorder)
                .multilineTextAlignment(.center)
                .font(.title2)
                .frame(maxWidth: 300)
        }
    }
    
    private var struggleStep: some View {
        VStack(spacing: 20) {
            Text("What's your biggest struggle right now?")
                .font(.title2)
                .bold()
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            VStack(spacing: 12) {
                ForEach(["Focus", "Sleep", "Stress", "Social life"], id: \.self) { option in
                    Button(action: {
                        struggle = option
                    }) {
                        HStack {
                            Text(option)
                                .font(.headline)
                            Spacer()
                            if struggle == option {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding()
                        .background(struggle == option ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
                        .cornerRadius(12)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var canProceed: Bool {
        switch step {
        case 0:
            return !age.isEmpty && Int(age) != nil
        case 1:
            return !name.isEmpty
        case 2:
            return !struggle.isEmpty
        default:
            return false
        }
    }
    
    private func saveUserData() {
        UserDefaults.standard.set(name, forKey: "userName")
        UserDefaults.standard.set(age, forKey: "userAge")
        UserDefaults.standard.set(struggle, forKey: "userStruggle")
    }
}

#Preview {
    OnboardingView(onComplete: {})
}
