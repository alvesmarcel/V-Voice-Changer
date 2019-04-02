import UIKit

class PlayerViewController: UIViewController {
    var recordedAudio: AudioFile?
    private var audioProcessor: AudioFXProcessor?
    
    override func viewDidLoad() {
        //let audioFile = try! PersistenceManager.shared.createNewAudioFile()
       if let audioFile = recordedAudio {
            do {
                try self.audioProcessor = AudioFXProcessor(audioFile: audioFile)
            } catch {
                print("Error instantiating the AudioFXProcessor\n\(error.localizedDescription)")
            }
       }
    }
    
    @IBAction func playButtonTapped(_ sender: Any) {
        var effect: AudioFXProcessor.Effects = .none
        
        audioProcessor?.play(withEffect: .chipmunk)
    }
    
}
