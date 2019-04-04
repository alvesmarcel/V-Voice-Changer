import UIKit
import AVFoundation
import Lottie

class RecorderViewController: UIViewController {
    @IBOutlet weak var recordButton: AnimationView!
    private var audioRecorder: AVAudioRecorder?
    private var audioSession = AVAudioSession.sharedInstance()
}

// MARK: - Lifecycle
extension RecorderViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureAudioRecorder()
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground(notification:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        super.viewWillDisappear(animated)
    }
}

// MARK: - Actions
extension RecorderViewController {
    @objc func recordButtonTapped() {
        if let recorder = self.audioRecorder {
            if recorder.isRecording {
                recorder.stop()
                recordButton.stop()
            } else {
                recorder.record()
                recordButton.play()
            }
        }
    }
}

// MARK: - AVAudioRecorderDelegate
extension RecorderViewController: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            guard let playerVC = storyboard?.instantiateViewController(withIdentifier: "PlayerViewController") as? PlayerViewController else {
                print("PlayerViewController could not be instantiated")
                return
            }
            playerVC.recordedAudio = PersistenceManager.shared.currentAudioFile
            self.show(playerVC, sender: self)
        } else {
            Alerts.show(error: .recording, viewController: self)
        }
    }
}

// MARK: - Helpers
extension RecorderViewController {
    func configureAudioRecorder() {
        var audioFile: AudioFile
        
        // Create new audio file
        do {
            try audioFile = PersistenceManager.shared.createNewAudioFile()
        } catch {
            Alerts.show(error: .url, viewController: self)
            return
        }
        
        // Set audio session active
        do {
            try self.audioSession.setActive(true)
        } catch {
            Alerts.show(error: .audioSession, viewController: self)
            return
        }
        
        // Initialize AVAudioRecorder
        do {
            let recordSettings = [AVFormatIDKey : kAudioFormatMPEG4AAC]
            try self.audioRecorder = AVAudioRecorder(url: audioFile.url, settings: recordSettings)
            self.audioRecorder!.delegate = self
        } catch {
            Alerts.show(error: .audioRecorder, viewController: self)
            return
        }
    }
    
    func configureView() {
        // Set up navigation bar
        title = "" // Removes the "Back" title from the navigation bar back button in the next screen
        navigationController?.navigationBar.shadowImage = UIImage() // Removes the separator line of the navigation bar
        navigationController?.navigationBar.barTintColor = UIColor(red: 16.0/255, green: 7.0/255, blue: 30.0/255, alpha: 1.0)
        navigationController?.navigationBar.tintColor = .white
        
        // Set up the record button and its animation
        let touchUpInside = UITapGestureRecognizer(target: self, action: #selector(recordButtonTapped))
        recordButton.addGestureRecognizer(touchUpInside)
        recordButton.animation = Animation.named("record_button_animation")
        recordButton.loopMode = .loop
    }
    
    @objc func applicationDidEnterBackground(notification: Notification) {
        // Improves UX by avoiding making the user thinks that the app was still recording
        if let recorder = audioRecorder {
            recorder.stop()
        }
    }
}
