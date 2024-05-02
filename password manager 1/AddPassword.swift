//
//  AddPassword.swift
//  password manager 1
//
//  Created by Thiru on 01/05/24.
//



import SwiftUI

struct AddPasswordView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss

    @State private var accountName: String = ""
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var isPasswordVisible: Bool = false
    @State private var showErrorAlert: Bool = false
    @State private var errorMessage: String = ""

    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            TextField("Account Name", text: $accountName)
                .padding()
                .background(Color.blue.opacity(0.5))
                .cornerRadius(12)
                .frame(height: 48)

            TextField("Username", text: $username)
                .padding()
                .background(Color.blue.opacity(0.5))
                .cornerRadius(12)
                .frame(height: 48)

            HStack {
                if isPasswordVisible {
                    TextField("Password", text: $password)
                        .padding()
                        .background(Color.blue.opacity(0.5))
                        .cornerRadius(12)
                        .frame(height: 48)
                } else {
                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color.blue.opacity(0.5))
                        .cornerRadius(12)
                        .frame(height: 48)
                }

                // Toggle button for password visibility
                Button(action: {
                    isPasswordVisible.toggle()
                }) {
                    Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                        .foregroundColor(.gray)
                }
                .padding(.trailing, 10)
            }

            Button(action: addNewPassword) {
                Text("Add New Password")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .alert(isPresented: $showErrorAlert) {
                Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
        }
        .padding(20)
    }

    private func addNewPassword() {
        let item = PasswordData(context: viewContext)
        item.pid = UUID().uuidString
        item.accountName = accountName
        item.username = username
        item.password = password

        do {
            try viewContext.save()
            dismiss()
        } catch {
            errorMessage = "Failed to save password. Please try again."
            showErrorAlert = true
        }
    }
}

#Preview {
    AddPasswordView()
}

