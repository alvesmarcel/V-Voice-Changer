import UIKit

class PlayerViewController: UIViewController {
    
    @IBOutlet weak var turtleButton: UIButton!
    @IBOutlet weak var rabbitButton: UIButton!
    @IBOutlet weak var alienButton: UIButton!
    @IBOutlet weak var darthButton: UIButton!
    @IBOutlet weak var shaoButton: UIButton!
    @IBOutlet weak var jigsawButton: UIButton!
    
    private var selectedButton: UIButton?
    
    var recordedAudio: AudioFile?
    private var audioProcessor: AudioFXProcessor?
    private enum ButtonIdentifier: String {
        case TurtleButton, RabbitButton, AlienButton, DarthButton, ShaoButton, JigsawButton
    }
}

// MARK: - Lifecycle
extension PlayerViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        if let audioFile = recordedAudio {
            do {
                try self.audioProcessor = AudioFXProcessor(audioFile: audioFile)
            } catch {
                print("Error instantiating the AudioFXProcessor\n\(error.localizedDescription)")
            }
        }
        let shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareButtonTapped))
        self.navigationItem.rightBarButtonItem  = shareButton
    }
}

// MARK: - Actions
extension PlayerViewController {
    @IBAction func playButtonTapped(_ sender: UIButton) {
        guard let identifier = sender.restorationIdentifier, let enumId = ButtonIdentifier(rawValue: identifier) else { return }
        configureButtonUI(button: sender)
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
    
    @objc func shareButtonTapped() {
        guard let audio = recordedAudio else { return }
        let activityViewController = UIActivityViewController(activityItems: [audio.url], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        activityViewController.excludedActivityTypes = [.airDrop]
        self.present(activityViewController, animated: true, completion: nil)
    }
}

// MARK: - Helper
extension PlayerViewController {
    func configureButtonUI(button: UIButton) {
        button.isSelected = true
        if let previousButton = selectedButton, previousButton != button {
            previousButton.isSelected = false
        }
        selectedButton = button
    }
}
