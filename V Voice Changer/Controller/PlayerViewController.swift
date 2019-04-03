import UIKit

class PlayerViewController: UIViewController {
    var recordedAudio: AudioFile?
    private var audioProcessor: AudioFXProcessor?
    private enum ButtonIdentifier: String {
        case TurtleButton, RabbitButton, AlienButton, DarthButton, ShaoButton, JigsawButton
    }
}

// MARK: - Lifecycle
extension PlayerViewController {
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

// MARK: - Actions
extension PlayerViewController {
    @IBAction func playButtonTapped(_ sender: UIButton) {
        guard let identifier = sender.restorationIdentifier, let enumId = ButtonIdentifier(rawValue: identifier) else { return }
        var effect: AudioFXProcessor.Effects = .none
        switch enumId {
        case .TurtleButton:
            effect = .slow
        case .RabbitButton:
            effect = .fast
        case .AlienButton:
            effect = .chipmunk
        case .DarthButton:
            effect = .darthvader
        case .ShaoButton:
            effect = .shaokahn
        case .JigsawButton:
            effect = .jigsaw
        }
        audioProcessor?.play(withEffect: effect)
    }
}
