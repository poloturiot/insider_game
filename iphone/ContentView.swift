import SwiftUI

struct ContentView: View {
    @State private var roles = ["Master", "Insider", "Commoner", "Commoner"].shuffled()
    @State private var playerNames = ["", "", "", ""]
    @State private var currentRole: String = ""
    @State private var showRole: Bool = false
    @State private var masterRevealed: Bool = false
    @State private var secretWord: String = ""
    @State private var showSecretWord: Bool = false
    @State private var timeRemaining = 300
    @State private var timerRunning = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Insider").font(.largeTitle).padding()
            
            // Player Name Input and Role Reveal Section
            ForEach(0..<4) { index in
                HStack {
                    TextField("Player \(index + 1) Name", text: $playerNames[index])
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    Button(action: {
                        currentRole = roles[index]
                        showRole.toggle()
                    }, label: {
                        Text("See Role")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    })
                    .onLongPressGesture(minimumDuration: 0.1) {
                        currentRole = ""
                    }
                }
            }
            
            // Show the role when the button is pressed
            if showRole {
                Text("Your Role: \(currentRole)").font(.title2)
            }
            
            // Master Reveal Button
            if !masterRevealed {
                Button("Reveal Master") {
                    revealMaster()
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            
            // Secret Word and Timer Section
            if masterRevealed {
                Text("Master Revealed!")
                Button("See Secret Word") {
                    showSecretWord.toggle()
                }
                .padding()
                .background(Color.orange)
                .foregroundColor(.white)
                .cornerRadius(10)
                
                if showSecretWord {
                    Text("Secret Word: \(secretWord)").font(.title2)
                }
                
                Button("Start Timer") {
                    startTimer()
                }
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(10)
                
                if timerRunning {
                    Text("Time Remaining: \(formatTime(seconds: timeRemaining))")
                        .font(.title2)
                        .padding()
                }
            }
            
            Spacer()
        }
        .onAppear {
            fetchRandomWord()
        }
    }
    
    // Function to reveal the master
    func revealMaster() {
        let masterIndex = roles.firstIndex(of: "Master") ?? 0
        let masterName = playerNames[masterIndex].isEmpty ? "Player \(masterIndex + 1)" : playerNames[masterIndex]
        showRole = false
        currentRole = "\(masterName) is the Master"
        masterRevealed = true
    }
    
    // Function to start a 5-minute timer
    func startTimer() {
        if !timerRunning {
            timerRunning = true
            timeRemaining = 300
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                if timeRemaining > 0 {
                    timeRemaining -= 1
                } else {
                    timer.invalidate()
                    timerRunning = false
                }
            }
        }
    }
    
    // Function to format the time
    func formatTime(seconds: Int) -> String {
        let minutes = seconds / 60
        let seconds = seconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // Function to fetch a random word
    func fetchRandomWord() {
        guard let url = URL(string: "https://random-word-api.herokuapp.com/word?number=1") else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                let word = try? JSONDecoder().decode([String].self, from: data)
                DispatchQueue.main.async {
                    self.secretWord = word?.first ?? "Error fetching word"
                }
            } else {
                DispatchQueue.main.async {
                    self.secretWord = "Error fetching word"
                }
            }
        }.resume()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
