import UIKit
import AVFoundation
import Lottie

class RecorderViewController: UIViewController {
    @IBOutlet weak var recordButton: AnimationView!
    @IBOutlet weak var recordingAnimationView: AnimationView!
    private var audioRecorder: AVAudioRecorder?
}

// MARK: - Lifecycle
extension RecorderViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        configureInitialUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        requestPermission()
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground(notification:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        resetAnimations()
        super.viewWillDisappear(animated)
    }
}

// MARK: - Actions
extension RecorderViewController {
    @objc func recordButtonTapped() {
        if let recorder = self.audioRecorder {
            if recorder.isRecording {
                recorder.stop()
            } else {
                startAnimations()
                recorder.record()
            }
        } else {
            requestPermission()
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
            Alerts.present(error: .recording, sender: self)
        }
    }
}

// MARK: - Helpers
extension RecorderViewController {
    func requestPermission() {
        switch AVAudioSession.sharedInstance().recordPermission {
        case AVAudioSessionRecordPermission.granted:
            configureAudioRecorder()
        case AVAudioSessionRecordPermission.denied:
            Alerts.presentPermissionDeniedAlert(sender: self)
        case AVAudioSessionRecordPermission.undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission({ (granted) in
                if granted {
                    self.configureAudioRecorder()
                } else {
                    Alerts.presentPermissionDeniedAlert(sender: self)
                }
            })
        @unknown default:
            print("Unknown error")
        }
    }
    
    func configureAudioRecorder() {
        var audioFile: AudioFile
        
        // Create new audio file
        do {
            try audioFile = PersistenceManager.shared.createNewAudioFile()
        } catch {
            Alerts.present(error: .url, sender: self)
            return
        }
        
        // Set audio session active
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            Alerts.present(error: .audioSession, sender: self)
            return
        }
        
        // Initialize AVAudioRecorder
        do {
            let recordSettings = [AVFormatIDKey : kAudioFormatMPEG4AAC]
            try self.audioRecorder = AVAudioRecorder(url: audioFile.url, settings: recordSettings)
            self.audioRecorder!.delegate = self
        } catch {
            Alerts.present(error: .audioRecorder, sender: self)
            return
        }
    }
    
    func configureInitialUI() {
        // Set up navigation bar
        title = "" // Removes the "Back" title from the navigation bar back button in the next screen
        navigationController?.navigationBar.shadowImage = UIImage() // Removes the separator line of the navigation bar
        navigationController?.navigationBar.barTintColor = UIColor(red: 16.0/255, green: 7.0/255, blue: 30.0/255, alpha: 1.0)
        navigationController?.navigationBar.tintColor = .white
        
        // Configure animations
        resetAnimations()
    }
    
    func resetAnimations() {
        // Set up the record button and its animation
        let touchUpInside = UITapGestureRecognizer(target: self, action: #selector(recordButtonTapped))
        recordButton.addGestureRecognizer(touchUpInside)
        recordButton.animation = Animation.named("record_button_animation")
        recordButton.loopMode = .loop
        
        recordingAnimationView.animation = Animation.named("recording_animation")
        recordingAnimationView.loopMode = .loop
    }
    
    func startAnimations() {
        recordButton.play()
        recordingAnimationView.play()
    }
    
    @objc func applicationDidEnterBackground(notification: Notification) {
        // Improves UX by avoiding making the user thinks that the app was still recording
        if let recorder = audioRecorder {
            recorder.stop()
        }
    }
}
