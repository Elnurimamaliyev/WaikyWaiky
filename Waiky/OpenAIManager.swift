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
    
    func generateNudge(
        mood: Int,
        sleepQuality: Int,
        heartRate: Double?,
        sleepHours: Double?,
        completion: @escaping (String?) -> Void
    ) {
        let prompt = buildPrompt(mood: mood, sleepQuality: sleepQuality, heartRate: heartRate, sleepHours: sleepHours)
        
        guard let url = URL(string: endpoint) else {
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "model": "gpt-4",
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
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: requestBody) else {
            completion(nil)
            return
        }
        
        request.httpBody = httpBody
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("❌ OpenAI API error: \(error?.localizedDescription ?? "unknown")")
                completion(nil)
                return
            }
            
            if let jsonResponse = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let choices = jsonResponse["choices"] as? [[String: Any]],
               let firstChoice = choices.first,
               let message = firstChoice["message"] as? [String: Any],
               let content = message["content"] as? String {
                DispatchQueue.main.async {
                    completion(content.trimmingCharacters(in: .whitespacesAndNewlines))
                }
            } else {
                print("❌ Failed to parse OpenAI response")
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Response: \(responseString)")
                }
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }.resume()
    }
    
    private func buildPrompt(mood: Int, sleepQuality: Int, heartRate: Double?, sleepHours: Double?) -> String {
        var prompt = "User check-in:\n"
        prompt += "- Mood: \(mood)/5\n"
        prompt += "- Sleep quality: \(sleepQuality)/5\n"
        
        if let hr = heartRate {
            prompt += "- Heart rate: \(Int(hr)) bpm\n"
        }
        
        if let sleep = sleepHours {
            prompt += "- Sleep duration: \(String(format: "%.1f", sleep)) hours\n"
        }
        
        prompt += "\nProvide a brief, actionable wellness nudge."
        
        return prompt
    }
}
