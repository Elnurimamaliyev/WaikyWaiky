//
//  AIChatView.swift
//  Waiky
//
//  Created by Elnur Imamaliyev on 01.08.2026.
//

import SwiftUI

struct ChatMessage: Identifiable {
    let id = UUID()
    let content: String
    let isUser: Bool
    let timestamp: Date
}

struct AIChatView: View {
    @State private var messages: [ChatMessage] = [
        ChatMessage(content: "Hi! I'm Waiky, your personal wellness companion. How can I support you today?", isUser: false, timestamp: Date())
    ]
    @State private var newMessage: String = ""
    @State private var isLoading = false
    @State private var openAIManager = OpenAIManager()
    @AppStorage("userName") private var userName: String = ""
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Messages
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(messages) { message in
                                ChatBubble(message: message)
                                    .id(message.id)
                            }
                            
                            if isLoading {
                                HStack {
                                    ProgressView()
                                        .padding(.horizontal)
                                    Text("Waiky is typing...")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Spacer()
                                }
                                .padding()
                            }
                        }
                        .padding()
                    }
                    .onChange(of: messages.count) { _, _ in
                        if let lastMessage = messages.last {
                            withAnimation {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }
                
                Divider()
                
                // Input field
                HStack(spacing: 12) {
                    TextField("Type your message...", text: $newMessage, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(1...4)
                        .autocorrectionDisabled()
                    
                    Button {
                        sendMessage()
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title2)
                            .foregroundColor(newMessage.isEmpty ? .gray : .blue)
                    }
                    .disabled(newMessage.isEmpty || isLoading)
                }
                .padding()
            }
            .navigationTitle("Talk to Waiky")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func sendMessage() {
        guard !newMessage.isEmpty else { return }
        
        let userMessage = ChatMessage(content: newMessage, isUser: true, timestamp: Date())
        messages.append(userMessage)
        
        let messageText = newMessage
        newMessage = ""
        isLoading = true
        
        // Generate AI response
        generateAIResponse(for: messageText)
    }
    
    private func generateAIResponse(for userMessage: String) {
        openAIManager.generateChatResponse(
            userMessage: userMessage,
            userName: userName,
            conversationHistory: messages
        ) { response in
            isLoading = false
            
            let aiMessage = ChatMessage(
                content: response ?? "I'm having trouble responding right now. Can you try again?",
                isUser: false,
                timestamp: Date()
            )
            messages.append(aiMessage)
        }
    }
}

struct ChatBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
            }
            
            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .padding(12)
                    .background(message.isUser ? Color.blue : Color.gray.opacity(0.2))
                    .foregroundColor(message.isUser ? .white : .primary)
                    .cornerRadius(16)
                
                Text(message.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: 280, alignment: message.isUser ? .trailing : .leading)
            
            if !message.isUser {
                Spacer()
            }
        }
    }
}

#Preview {
    AIChatView()
}
