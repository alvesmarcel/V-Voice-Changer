import UIKit

class PlayerViewController: UIViewController {
    var recordedAudio: AudioFile?
    private var audioProcessor: AudioFXProcessor?
    
    override func viewDidLoad() {
        if let audioFile = recordedAudio {
            do {
                try self.audioProcessor = AudioFXProcessor(audioFile: audioFile)
            } catch {
                print("Error instantiating the AudioFXProcessor\n\(error.localizedDescription)")
            }
        }
    }
}
