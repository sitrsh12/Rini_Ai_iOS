import SwiftUI
import UIKit

struct CustomKeyboardView: View {
    @State private var inputText: String = "Hello!! How are you today"
    @State private var responseText: String = ""
    let viewController: KeyboardViewController?
    
    let buttonTitlesTop = [
           "Funny", "Casual", "Short",
           "Sarcastic", "Professional", "Include Emojis",
           "Polite", "Email", "Assertive"
       ]
    
    @State private var emotions: Array<Int> = []
    @State private var emotionVariable: String = ""
    @State private var writeToggle = false
    @State private var grammarToggle = false
    @State private var selectedIndex: Int? = nil
    @State private var emotionsList: Array<String> = []
    @State private var keyToggle: Bool = false
    @State private var responsesArr: [String] = []
       
    var body: some View {
        if(keyToggle){
                ScrollView {
                    VStack(spacing: 20) {
                        if !responsesArr.isEmpty {
                            ForEach(responsesArr, id: \.self) { response in
                            Text(response)
                                .font(.caption)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(Color(white: 0.2))
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                                .onTapGesture {
                                    viewController?.replaceText(with: response)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    
                }
            
           }else{
               VStack(spacing: 10) {
                   VStack(spacing: 10) {
                       Button(action: {
                           if((viewController?.getCurrentText()) != nil){
                               processText(viewController?.getCurrentText() ?? "")
                               grammarToggle = true
                           }
                       }) {
                           Text(!grammarToggle ? "Fix Grammar" : "Writing...")
                               .italic(grammarToggle)
                               .padding(.top, 10)
                               .padding(.bottom, 10)
                               .font(.footnote)
                               .frame(maxWidth: .infinity, maxHeight: .infinity)
                               .background(Color.white)
                               .foregroundColor(Color.black)
                               .cornerRadius(8)
                           
                       }
                       .padding(.top, 20)
                       .padding(.horizontal, 15)
                       //                   .overlay(
                       //                               Group {
                       //                                   if showToast {
                       //                                       ToastView(message: "Grammer Fixing",isShowing: true)
                       //                                           .transition(.move(edge: .bottom))
                       //                                           .animation(.easeInOut)
                       //                                           .onTapGesture {
                       //                                               showToast = false
                       //                                           }
                       //                                   }
                       //                               }
                       //                           )
                   }
                   
                   //               Text(emotionsList.joined(separator: " "))

                   
                   LazyVGrid(columns: [GridItem(), GridItem(), GridItem()], spacing: 10) {
                       ForEach(buttonTitlesTop.indices, id: \.self) { index in
                           ButtonView(title: buttonTitlesTop[index], index: index, selectedIndices: $emotions){
                               handleButtonTap(index: index)
                           }
                           
                       }
                   }
                   .padding(.horizontal)
                   .padding(.top, 10)
                   
                   Spacer()
               }
               
               .padding(.horizontal)
               .background(Color(.systemGray4))
               .frame(maxHeight: .none)
           }
               // Bottom Row of Buttons
           VStack(spacing: 20){
               HStack(spacing: 10) {
                   Button(action: {
                       if(!responsesArr .isEmpty){
                           responsesArr = []
                           keyToggle.toggle()
                       }else{
                           viewController?.switchToNextKeyboard()
                       }
                   }) {
                       Text("↺")
                           .frame(maxWidth: 60)
                           .frame(height: 40)
                           .background(Color.gray)
                           .foregroundColor(Color(.systemGray6))
                           .cornerRadius(8)
                   }
                   
                   Button(action: {
                       if((viewController?.getCurrentText()) != nil){
                           processText(viewController?.getCurrentText() ?? "")
                           writeToggle = true
                       }
                   }) {
                       Text(!writeToggle ? "Write" : "Writing...")
                           .italic(writeToggle)
                           .frame(maxWidth: .infinity)
                           .frame(height: 40)
                           .background(Color.green)
                           .foregroundColor(.white)
                           .cornerRadius(8)
                   }
                   
                   
                   Button(action: {
                       viewController?.dismissKeyboardProgrammatically()
                   }) {
                       Text("x")
                           .frame(maxWidth: 50)
                           .frame(height: 40)
                           .background(Color.gray)
                           .foregroundColor(Color(.systemGray6))
                           .cornerRadius(8)
                   }
               }

           }
           .padding(.horizontal)
           .padding(.top, 20)
           .background(Color(.systemGray4))
        }
    func handleButtonTap(index: Int) {
        if(index == 0){
            emotionVariable = "FUNNY"
        }else if(index == 1){
            emotionVariable = "CASUAL"
        }else if(index == 2){
            emotionVariable = "SHORT"
        }else if(index == 3){
            emotionVariable = "SARCASTIC"
        }else if(index == 4){
            emotionVariable = "PROFESSIONAL"
        }else if(index == 5){
            emotionVariable = "EMOJI"
        }else if(index == 6){
            emotionVariable = "POLITE"
        }else if(index == 7){
            emotionVariable = "EMAIL"
        }else{
            emotionVariable = "ASSERTIVE"
        }
        if emotions.contains(index) {
            emotions.removeAll { $0 == index }
        } else {
            emotions.append(index)
        }
        if let i = emotionsList.firstIndex(of: emotionVariable) {
            emotionsList.remove(at: i)
        } else {
            emotionsList.append(emotionVariable)
        }
        print(emotionsList)
    }
                

    private func processText(_ text: String) {
        let url = URL(string: "http://15.207.86.173:8080/bot/v1/chat")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "writingStyle": emotionsList,
            "message": text
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                // Ensure that the error is reported on the main thread
                DispatchQueue.main.async {
                    responseText = "Error: \(error.localizedDescription)"
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    responseText = "No data received."
                }
                return
            }
            
            // Parse JSON and update UI on the main thread
            if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                if let responses = jsonObject["responses"] as? [String]
//                    ,let firstResponse = responses.first
                {
                    DispatchQueue.main.async {
                         responsesArr = responses
//                        responseText = firstResponse
                        keyToggle = true
                        writeToggle = false
                        grammarToggle = false
                    }
                } else {
                    DispatchQueue.main.async {
                        responseText = "No valid responses found."
                    }
                }
            } else {
                DispatchQueue.main.async {
                    responseText = "Failed to parse JSON."
                }
            }
        }
        
        task.resume()
    }

}

struct CustomKeyboardView_Previews: PreviewProvider {
    static var previews: some View {
        CustomKeyboardView(viewController: KeyboardViewController())
    }
}
struct ToastView: View {
    var message: String
    var isShowing: Bool

    var body: some View {
        VStack {
            Spacer()
            if isShowing {
                HStack {
                    Spacer()
                    Text(message)
                        .padding()
                        .background(Color.black.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding()
                    Spacer()
                }
            }
        }
    }
}
struct ButtonView: View {
    let title: String
    let index: Int
    @Binding var selectedIndices: [Int]
    let onTap: () -> Void
    var body: some View {
        Button(action: {
            onTap()
        }) {
            Text(title)
                .padding(.top, 10)
                .padding(.bottom, 10)
                .font(.footnote)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(selectedIndices.contains(index) ? Color.green : Color.white)
                .foregroundColor(selectedIndices.contains(index) ? Color.white : Color.gray)
                .cornerRadius(8)
        }
        .padding(5)
    }

}
