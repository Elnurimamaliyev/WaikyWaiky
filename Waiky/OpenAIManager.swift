//
//  OpenAIManager.swift
//  Waiky
//
//  Created by Elnur Imamaliyev on 01.08.2026.
//

import Foundation

class OpenAIManager {
    private let apiKey = "REDACTED"
    private let endpoint = "https://api.openai.com/v1/chat/completions"
    
    // Toggle this to switch between mock and real API
    // Set to false when you add OpenAI credits
    private let useMockResponse = true
    
    func generateNudge(
        mood: Int,
        sleepQuality: Int,
        heartRate: Double?,
        sleepHours: Double?,
        isBusyDay: Bool = false,
        completion: @escaping (String?) -> Void
    ) {
        // Use mock response if enabled
        if useMockResponse {
            generateMockNudge(mood: mood, sleepQuality: sleepQuality, heartRate: heartRate, sleepHours: sleepHours, isBusyDay: isBusyDay, completion: completion)
            return
        }
        
        let prompt = buildPrompt(mood: mood, sleepQuality: sleepQuality, heartRate: heartRate, sleepHours: sleepHours, isBusyDay: isBusyDay)
        
        guard let url = URL(string: endpoint) else {
            print("❌ Failed to create URL from endpoint: \(endpoint)")
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let modelName = "gpt-3.5-turbo"
        let requestBody: [String: Any] = [
            "model": modelName,
            "messages": [
                [
                    "role": "system",
                    "content": "You are a caring wellness coach. Provide a brief, actionable, personalized nudge based on the user's check-in data. Keep it under 2 sentences and friendly."
                ],
                [
                    "role": "user",
                    "content": prompt
                ]
            ],
            "max_tokens": 100,
            "temperature": 0.7
        ]
        
        // Debug logging before the call
        print("🔵 OpenAI Request:")
        print("   URL: \(url.absoluteString)")
        print("   Model: \(modelName)")
        print("   Prompt: \(prompt)")
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: requestBody) else {
            print("❌ Failed to serialize request body to JSON")
            completion(nil)
            return
        }
        
        request.httpBody = httpBody
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            // Log HTTP response status
            if let httpResponse = response as? HTTPURLResponse {
                print("🔵 OpenAI Response Status Code: \(httpResponse.statusCode)")
            }
            
            // Check for network errors
            if let error = error {
                print("❌ OpenAI Network Error: \(error)")
                print("   Error Description: \(error.localizedDescription)")
                if let nsError = error as NSError? {
                    print("   Error Domain: \(nsError.domain)")
                    print("   Error Code: \(nsError.code)")
                    print("   Error UserInfo: \(nsError.userInfo)")
                }
                completion(nil)
                return
            }
            
            guard let data = data else {
                print("❌ No data received from OpenAI")
                completion(nil)
                return
            }
            
            // Always log the raw response
            if let responseString = String(data: data, encoding: .utf8) {
                print("🔵 OpenAI Raw Response: \(responseString)")
            }
            
            if let jsonResponse = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let choices = jsonResponse["choices"] as? [[String: Any]],
               let firstChoice = choices.first,
               let message = firstChoice["message"] as? [String: Any],
               let content = message["content"] as? String {
                print("✅ OpenAI Success - Generated nudge: \(content)")
                DispatchQueue.main.async {
                    completion(content.trimmingCharacters(in: .whitespacesAndNewlines))
                }
            } else {
                print("❌ Failed to parse OpenAI response")
                if let jsonResponse = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    print("   Parsed JSON: \(jsonResponse)")
                }
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }.resume()
    }
    
    private func generateMockNudge(
        mood: Int,
        sleepQuality: Int,
        heartRate: Double?,
        sleepHours: Double?,
        isBusyDay: Bool,
        completion: @escaping (String?) -> Void
    ) {
        print("🤖 Using Mock AI Response")
        
        // Simulate network delay for realistic feel
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            var nudge = ""
            
            // Generate personalized mock response based on inputs
            if mood <= 2 {
                nudge = "Your mood seems low today. Try a 10-minute walk outside or call a friend to lift your spirits!"
            } else if mood >= 4 {
                nudge = "You're feeling great! Keep that positive energy going with some light exercise or a creative activity."
            } else {
                nudge = "You're doing okay! A quick break or some deep breathing could help boost your energy and focus."
            }
            
            // Add busy day context
            if isBusyDay {
                nudge += " It looks like you have a busy day ahead—remember to take short breaks between meetings to recharge."
            }
            
            // Add sleep-specific advice if available
            if let sleep = sleepHours {
                if sleep < 6 {
                    nudge += " Try to get more rest tonight—aim for 7-8 hours."
                } else if sleep > 9 {
                    nudge += " You got plenty of sleep! Use that energy wisely today."
                }
            }
            
            // Add heart rate comment if available and notable
            if let hr = heartRate {
                if hr > 100 {
                    nudge += " Your heart rate is a bit elevated—consider some relaxation techniques."
                } else if hr < 60 {
                    nudge += " Your resting heart rate looks great!"
                }
            }
            
            print("✅ Mock AI Generated: \(nudge)")
            completion(nudge)
        }
    }
    
    private func buildPrompt(mood: Int, sleepQuality: Int, heartRate: Double?, sleepHours: Double?, isBusyDay: Bool = false) -> String {
        var prompt = "User check-in:\n"
        prompt += "- Mood: \(mood)/5\n"
        prompt += "- Sleep quality: \(sleepQuality)/5\n"
        
        if let hr = heartRate {
            prompt += "- Heart rate: \(Int(hr)) bpm\n"
        }
        
        if let sleep = sleepHours {
            prompt += "- Sleep duration: \(String(format: "%.1f", sleep)) hours\n"
        }
        
        if isBusyDay {
            prompt += "- Schedule: Busy day (4+ calendar events)\n"
        }
        
        prompt += "\nProvide a brief, actionable wellness nudge."
        
        return prompt
    }
    
    func generateChatResponse(
        userMessage: String,
        userName: String,
        conversationHistory: [ChatMessage],
        completion: @escaping (String?) -> Void
    ) {
        // Use mock response if enabled
        if useMockResponse {
            generateMockChatResponse(userMessage: userMessage, userName: userName, completion: completion)
            return
        }
        
        // Real OpenAI chat implementation would go here
        // For now, fall back to mock
        generateMockChatResponse(userMessage: userMessage, userName: userName, completion: completion)
    }
    
    private func generateMockChatResponse(
        userMessage: String,
        userName: String,
        completion: @escaping (String?) -> Void
    ) {
        print("🤖 Generating mock chat response for: \(userMessage)")
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            var response = ""
            
            let lowercased = userMessage.lowercased()
            
            // Keyword-based responses
            if lowercased.contains("stress") || lowercased.contains("anxious") || lowercased.contains("overwhelm") {
                response = "I hear that you're feeling stressed, \(userName). Try the 4-7-8 breathing technique: breathe in for 4 seconds, hold for 7, exhale for 8. It can help calm your nervous system. What's the main source of your stress right now?"
            } else if lowercased.contains("sleep") || lowercased.contains("tired") || lowercased.contains("exhausted") {
                response = "Sleep is so important, \(userName). Try avoiding screens 1 hour before bed, and keep your room cool and dark. Would you like some tips for better sleep hygiene?"
            } else if lowercased.contains("sad") || lowercased.contains("down") || lowercased.contains("depressed") {
                response = "I'm sorry you're feeling down. It's okay to have these feelings. Sometimes a short walk or talking to someone you trust can help. Is there something specific that's weighing on you?"
            } else if lowercased.contains("focus") || lowercased.contains("concentrate") || lowercased.contains("distracted") {
                response = "Having trouble focusing? Try the Pomodoro technique: 25 minutes of focused work, then a 5-minute break. Our Focus Session feature can help with that! What are you trying to work on?"
            } else if lowercased.contains("thank") {
                response = "You're very welcome, \(userName)! I'm here whenever you need support. Remember, small steps lead to big changes. 💙"
            } else if lowercased.contains("help") || lowercased.contains("how") {
                response = "I'm here to support your mental wellness journey! I can help with stress management, sleep tips, mood tracking, and focus techniques. What would be most helpful for you right now?"
            } else {
                response = "Thanks for sharing that with me, \(userName). How does that make you feel? I'm here to listen and support you."
            }
            
            print("✅ Mock chat response generated")
            completion(response)
        }
    }
}

