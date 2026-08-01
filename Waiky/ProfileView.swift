//
//  ProfileView.swift
//  Waiky
//
//  Created by Elnur Imamaliyev on 01.08.2026.
//

import SwiftUI

struct ProfileView: View {
    @AppStorage("userName") private var userName: String = ""
    @AppStorage("userAge") private var userAge: String = ""
    @AppStorage("userStruggle") private var userStruggle: String = ""
    
    @State private var editedName: String = ""
    @State private var editedAge: String = ""
    @State private var editedStruggle: String = ""
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Personal Information") {
                    HStack {
                        Text("Name")
                        Spacer()
                        TextField("Your name", text: $editedName)
                            .multilineTextAlignment(.trailing)
                            .autocorrectionDisabled()
                    }
                    
                    HStack {
                        Text("Age")
                        Spacer()
                        TextField("Your age", text: $editedAge)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .autocorrectionDisabled()
                    }
                }
                
                Section("Wellness Focus") {
                    Picker("Biggest Struggle", selection: $editedStruggle) {
                        Text("Focus").tag("Focus")
                        Text("Sleep").tag("Sleep")
                        Text("Stress").tag("Stress")
                        Text("Social life").tag("Social life")
                    }
                }
                
                Section {
                    Button("Save Changes") {
                        saveChanges()
                        dismiss()
                    }
                    .frame(maxWidth: .infinity)
                    .disabled(editedName.isEmpty || editedAge.isEmpty)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                loadCurrentValues()
            }
        }
    }
    
    private func loadCurrentValues() {
        editedName = userName
        editedAge = userAge
        editedStruggle = userStruggle.isEmpty ? "Focus" : userStruggle
    }
    
    private func saveChanges() {
        userName = editedName
        userAge = editedAge
        userStruggle = editedStruggle
        print("✅ Profile updated")
    }
}

#Preview {
    ProfileView()
}
