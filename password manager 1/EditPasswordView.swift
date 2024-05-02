//
//  EditPasswordView.swift
//  password manager 1
//
//  Created by Thiru on 02/05/24.
//

import SwiftUI

struct EditPasswordView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    var passwordData: PasswordData
    
    @State private var accountName: String
    @State private var username: String
    @State private var password: String
    
    // State variable to track password visibility
    @State private var isPasswordVisible: Bool = false
    
    // Initialize the state variables with the existing password data
    init(passwordData: PasswordData) {
        self.passwordData = passwordData
        _accountName = State(initialValue: passwordData.accountName ?? "")
        _username = State(initialValue: passwordData.username ?? "")
        _password = State(initialValue: passwordData.password ?? "")
    }
    
    var body: some View {
        VStack {
            TextField("Account Name", text: $accountName)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            TextField("Username", text: $username)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            // Password input with visibility toggle
            HStack {
                if isPasswordVisible {
                    TextField("Password", text: $password)
                        .padding()
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                } else {
                    SecureField("Password", text: $password)
                        .padding()
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                // Eye button to toggle password visibility
                Button(action: {
                    isPasswordVisible.toggle()
                }) {
                    Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                        .foregroundColor(.gray)
                }
            }
            
            Button(action: saveChanges) {
                Text("Save Changes")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
            }
        }
        .padding()
        .navigationTitle("Edit Password")
    }
    
    // Save the changes to the password data
    private func saveChanges() {
        passwordData.accountName = accountName
        passwordData.username = username
        passwordData.password = password
        
        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Failed to save changes: \(error)")
        }
    }
}
