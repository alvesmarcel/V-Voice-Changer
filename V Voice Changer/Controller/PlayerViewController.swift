import UIKit

class PlayerViewController: UIViewController {
    
    @IBOutlet weak var turtleButton: UIButton!
    @IBOutlet weak var rabbitButton: UIButton!
    @IBOutlet weak var alienButton: UIButton!
    @IBOutlet weak var darthButton: UIButton!
    @IBOutlet weak var shaoButton: UIButton!
    @IBOutlet weak var jigsawButton: UIButton!
    
    var recordedAudio: AudioFile?
    
    private var selectedButton: UIButton?
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
                Alerts.present(error: .audioEngine, sender: self)
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
        var effect: AudioFXProcessor.Effect = .none
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
        if let fileURL = urlFileForSelectedButton() {
            let activityViewController = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
            activityViewController.excludedActivityTypes = [.airDrop]
            self.present(activityViewController, animated: true, completion: nil)
        }
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
    
    func urlFileForSelectedButton() -> URL? {
        var url: URL?
        do {
            if let selected = selectedButton {
                switch selected {
                case turtleButton:
                    url = try PersistenceManager.shared.urlForEffect(.slow)
                case rabbitButton:
                    url = try PersistenceManager.shared.urlForEffect(.fast)
                case alienButton:
                    url = try PersistenceManager.shared.urlForEffect(.chipmunk)
                case darthButton:
                    url = try PersistenceManager.shared.urlForEffect(.darthvader)
                case shaoButton:
                    url = try PersistenceManager.shared.urlForEffect(.shaokahn)
                case jigsawButton:
                    url = try PersistenceManager.shared.urlForEffect(.jigsaw)
                default:
                    print("No known button selected")
                }
            }
        } catch {
            Alerts.present(error: .url, sender: self)
        }
        return url
    }
    
    func saveEffectsFiles() {
        for effect in AudioFXProcessor.Effect.allValues {
            audioProcessor?.manualAudioRender(effect: effect, completionHandler: { (url, error) in
                if let error = error {
                    print("Error rendering audio file.\n\(error.localizedDescription)")
                }
            })
        }
    }
}
