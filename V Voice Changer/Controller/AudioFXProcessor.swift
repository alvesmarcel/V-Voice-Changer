import AVFoundation

class AudioFXProcessor {
    enum Effects {
        case none
        case slow
        case fast
        case darthvader
        case chipmunk
        case jigsaw
        case shaokahn
    }
    
    private let audioPlayer: AVAudioPlayer!
    private let audioEngine: AVAudioEngine!
    private let avAudioFile: AVAudioFile!
    
    init(audioFile: AudioFile) throws {
        self.audioPlayer = try AVAudioPlayer(contentsOf: audioFile.url)
        self.audioPlayer.enableRate = true // required to change the audio rate
        self.audioEngine = AVAudioEngine()
        self.avAudioFile = try AVAudioFile(forReading: audioFile.url)
        print(avAudioFile.url)
    }
    
    private func getAudioUnits(effect: Effects) -> [AVAudioUnit] {
        switch effect {
        case .darthvader:
            let changePitchEffect = AVAudioUnitTimePitch()
            changePitchEffect.pitch = -1200
            return [changePitchEffect]
        default:
            return []
        }
    }
    
    private func playAudioPlayerEffect(_ effect: Effects) {
        self.audioPlayer.rate = effect == .slow ? 0.5 : 2.0
        audioPlayer.play()
    }
    
    private func playAudioEngineEffect(_ effect: Effects) {
        let audioPlayerNode = AVAudioPlayerNode()
        var previousNode: AVAudioNode = audioPlayerNode
        audioEngine.attach(previousNode)
        for audioUnit in getAudioUnits(effect: effect) {
            audioEngine.attach(audioUnit)
            audioEngine.connect(previousNode, to: audioUnit, format: nil)
            previousNode = audioUnit
        }
        audioEngine.connect(previousNode, to: audioEngine.outputNode, format: nil)
        
        audioPlayerNode.scheduleFile(avAudioFile, at: nil, completionHandler: nil)
        do {
            try audioEngine.start()
        } catch let error as NSError {
            print("Error starting audio engine.\n\(error.localizedDescription)")
        }
        
        audioPlayerNode.play()
    }
    
    private func stopAudio() {
        self.audioPlayer.stop()
        self.audioPlayer.currentTime = 0.0
        self.audioEngine.stop()
        self.audioEngine.reset()
    }
    
    func play(withEffect effect: Effects) {
        stopAudio()
        switch effect {
        case .none:
            break
        case .slow, .fast:
            playAudioPlayerEffect(effect)
        default:
            playAudioEngineEffect(effect)
        }
    }
}
