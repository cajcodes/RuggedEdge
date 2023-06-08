import SwiftUI

struct AIHelpdeskView: View {
    @State private var userInput: String = ""
    @State private var isHelpbotTyping: Bool = false
    @State private var messages: [(String, Bool)] = [( "Welcome to Rugged Edge Helpdesk! We provide intrinsically safe mobile connectivity to the industrial worker. Feel free to ask me anything about our products and services.", false)] // (message, isUserMessage)
    @State private var conversationHistory: [[String: Any]] = [["role": "system", "content": "You're a courteous AI helpdesk in RuggedEdge app, once ConnectIt Technologies. We offer safe mobile connectivity for industrial workers, enabling access to vital resources in hazardous areas. We're releasing two 5G devices, EdgeOne and Edge2, viewable in AR on the app and at ruggededge.ai. For unknown queries, suggest contacting us via phone or email above the chat, or visiting the website. More info and announcements coming soon."]] // Initialize conversation history with system message
    
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
                    if let url = URL(string: "tel://7133764500"), UIApplication.shared.canOpenURL(url) {
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
        let url = URL(string: "https://us-central1-codebot-project.cloudfunctions.net/chatBotGpt4")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                // Set isHelpbotTyping to false to hide "Helpbot is typing..."
                isHelpbotTyping = false
                
                // Handle errors
                if let error = error {
                    messages.append(("Error: \(error.localizedDescription)", false))
                    return
                }
                
                // Handle response
                if let data = data,
                   let responseData = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let botMessage = responseData["message"] as? String {
                    
                    // Append bot message to conversationHistory
                    conversationHistory.append(["role": "bot", "content": botMessage])
                    
                    // Append bot message to messages array for displaying
                    messages.append((botMessage, false))
                } else {
                    messages.append(("Unknown error", false))
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
