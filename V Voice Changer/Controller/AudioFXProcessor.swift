import AVFoundation

class AudioFXProcessor {
    enum Effects {
        case slow
        case fast
        case darthvader
        case chipmunk
        case jigsaw
        case shaokahn
    }
    
    private let audioPlayer: AVAudioPlayer!
    private let audioEngine: AVAudioEngine!
    
    init(audioFile: AudioFile) throws {
        self.audioPlayer = try AVAudioPlayer(contentsOf: audioFile.url)
        self.audioPlayer.enableRate = true // required to change the audio rate
        self.audioEngine = AVAudioEngine()
    }
    
    private func playAudioPlayerEffect(_ effect: Effects) {
        
    }
    
    private func playAudioEngineEffect(_ effect: Effects) {
        
    }
    
    func play(withEffect effect: Effects) {
        switch effect {
        case .chipmunk, .fast:
            playAudioPlayerEffect(effect)
        default:
            playAudioEngineEffect(effect)
        }
    }
}
