import SwiftUI

struct AIHelpdeskView: View {
    @ObservedObject private var keyboardResponder = KeyboardResponder()
    @State private var userInput: String = ""
    @State private var isHelpbotTyping: Bool = false
    @State private var messages: [(String, Bool)] = [( "Hi, I'm the RuggedEdge AI Assistant. How can I help you on your digital journey today?", false)] // (message, isUserMessage)
    @State private var conversationHistory: [[String: Any]] = [["role": "system", "content": "RuggedEdgeAIAssistant: You are the AI Helpdesk integrated in the RuggedEdge iOS app. Be professional, courteous, and brief. Provide concise responses and ask users questions to guide conversation. Located in Houston, RuggedEdge specializes in industrial digital transformation with purpose-built, industrial-grade, intrinsically-safe edge computing hubs with public/private 5G and enterprise-grade Wi-Fi 6 and Wi-Fi 6E connectivity ready to clip to your belt. Empower the future of industry with EdgeOne (class 1, div 1 & ATEX Zone 1) and EdgeTwo (class 1, div 2 & ATEX Zone 2) devices, seamlessly managed by the cloud-based EdgeConnect platform, which provides ease and reliability in managing connected devices and PPE like gas detectors, hearing protection, and handheld tools. Both devices ship August 2023. Both devices can be viewed in AR in the app. These are essential for operations and safety in the field. Visit our [products page](https://ruggededge.ai/products) for EdgeOne, EdgeTwo and EdgeConnect. Learn about Digital Tranformation, appilications, architecture, and industries on our [solutions page](https://ruggededge.ai/solutions). Our goals are to empower through innovation ([about page](https://ruggededge.ai/about)), enhance reliability, and reduce risks. Configure profiles and devices using EdgeConnect, and pair with tools. EdgeOne/Two provide alerts. For help, click 📞/✉️ above. FAQs are below the chat. Use Markdown for clarity when sharing steps, explanations, or URLs. Share steps one by one, asking for readiness before proceeding."]] // Initialize conversation history with system message
    
    var body: some View {
        VStack {
            // Logo and Contact Icons
            HStack {
                Image("logo_horizontal") // Replace "logo_horizontal" with your logo image name
                    .resizable()
                    .frame(width: 200, height: 20)
    
                Spacer()
    
                Button(action: {
                    // Action to contact via phone
                    if let url = URL(string: "tel://13463010008"), UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }) {
                    Image(systemName: "phone.fill")
                        .resizable()
                        .frame(width: 24, height: 24)
                }
    
                Button(action: {
                    // Action to contact via mail
                    if let url = URL(string: "mailto:vincent.higgins@ruggededge.ai"), UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }) {
                    Image(systemName: "envelope.fill")
                        .resizable()
                        .frame(width: 28, height: 22)
                }
            }
            .padding()
            
            // Conversation Area
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(messages.indices, id: \.self) { index in
                        MessageView(message: messages[index].0, isUserMessage: messages[index].1)
                    }

                    if isHelpbotTyping {
                        Text("Helpbot is typing...")
                            .italic()
                            .foregroundColor(.gray)
                    }
                }
                .padding()
            }

            // Input Field
            HStack {
                TextField("Type your message here...", text: $userInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.leading)

                Button(action: {
                    // Add action to send message
                    sendMessage()
                }) {
                    Image(systemName: "arrow.up.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .padding(.trailing)
                }
            }
            .padding(.bottom, keyboardResponder.currentHeight)
        }
    }
    
    private func sendMessage() {
        guard !userInput.isEmpty else { return }
        
        // Append user message to messages array
        messages.append((userInput, true))
        
        // Append user message to conversationHistory
        conversationHistory.append(["role": "user", "content": userInput])
        
        // Clear input
        userInput = ""
        
        // Set isHelpbotTyping to true to show "Helpbot is typing..."
        isHelpbotTyping = true
        
        // Create the request payload
        let payload: [String: Any] = ["messages": conversationHistory]
        
        // Call your Firebase function (replace with the correct URL)
        let url = URL(string: "https://us-central1-codebot-project.cloudfunctions.net/appChatBot")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: payload)
            request.httpBody = jsonData
            // Print out the request payload
            print("Request payload: \(payload)")
        } catch {
            print("Error: \(error.localizedDescription)")
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                // Set isHelpbotTyping to false to hide "Helpbot is typing..."
                isHelpbotTyping = false
                
                // Handle errors
                if let error = error {
                    messages.append(("Error: \(error.localizedDescription)", false))
                    print("Error in sendMessage:", error)
                    return
                }
                
                // Handle response
                if let data = data,
                   let responseData = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let botMessage = responseData["message"] as? String {
                    
                    // Print out the response data
                    print("Response data: \(responseData)")
                    
                    // Append bot message to messages array for displaying
                    messages.append((botMessage, false))
                } else {
                    messages.append(("Error: Unable to process your request.", false))
                    print("Error: Unexpected response data")
                }
            }
        }
        task.resume()
    }
}

struct MessageView: View {
    var message: String
    var isUserMessage: Bool
    
    var body: some View {
        HStack {
            if isUserMessage {
                Spacer()
            }
            
            Text(message)
                .padding(10)
                .background(isUserMessage ? Color.blue : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(10)
            
            if !isUserMessage {
                Spacer()
            }
        }
    }
}

struct AIHelpdeskView_Previews: PreviewProvider {
    static var previews: some View {
        AIHelpdeskView()
    }
}
