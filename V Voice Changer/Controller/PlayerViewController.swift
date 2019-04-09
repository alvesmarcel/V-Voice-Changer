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
        cleanPreviousFilesFromDirectory()
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
    
    override func viewWillDisappear(_ animated: Bool) {
        audioProcessor?.stop()
        super.viewWillDisappear(animated)
    }
}

// MARK: - Actions
extension PlayerViewController {
    @IBAction func playButtonTapped(_ sender: UIButton) {
        configureButtonUI(button: sender)
        let effect = effectForButton(sender)
        audioProcessor?.play(withEffect: effect)
    }
    
    @objc func shareButtonTapped() {
        guard let selected = selectedButton else { return }
        let effect = effectForButton(selected)
        
        guard let fileURL = try? PersistenceManager.shared.urlForEffect(effect) else { return }
        
        // If the file already exists, we don't need to process the audio again
        if !FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try audioProcessor?.manualAudioRender(effect: effect)
            } catch {
                Alerts.present(error: .audioRendering, sender: self)
                return
            }
        }
        
        let activityViewController = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        activityViewController.excludedActivityTypes = [.addToReadingList, .airDrop, .copyToPasteboard, .markupAsPDF, .openInIBooks, .print, .saveToCameraRoll]
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
    
    func effectForButton(_ button: UIButton) -> AudioFXProcessor.Effect {
        switch button {
        case turtleButton:
            return .slow
        case rabbitButton:
            return .fast
        case alienButton:
            return .chipmunk
        case darthButton:
            return .darthvader
        case shaoButton:
            return .shaokahn
        case jigsawButton:
            return .jigsaw
        default:
            return .none
        }
    }
    
    func cleanPreviousFilesFromDirectory() {
        for effect in AudioFXProcessor.Effect.allValues {
            guard let url = try? PersistenceManager.shared.urlForEffect(effect) else { return }
            try? FileManager.default.removeItem(at: url)
        }
    }
}
