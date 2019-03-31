import UIKit
import AVFoundation

class RecordViewController: UIViewController {
    private var audioRecorder: AVAudioRecorder!
    private var audioSession = AVAudioSession.sharedInstance()
}

// MARK: - Actions
extension RecordViewController {
    @IBAction func recordButtonTapped(_ sender: UIButton) {
        if audioRecorder == nil {
            configureAudioRecorder()
        }
        if self.audioRecorder.isRecording {
            self.audioRecorder.stop()
        } else {
            self.audioRecorder.record()
        }
    }
}

// MARK: - AVAudioRecorderDelegate
extension RecordViewController: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            // Should go to the next view controller
        } else {
            print("There was a problem recording the audio")
        }
    }
}

// MARK: - Helpers
extension RecordViewController {
    func configureAudioRecorder() {
        // This stops any other audio that is currently playing; should be called only when the user taps the record button
        try! self.audioSession.setActive(true)
        guard let audioURL = PersistenceManager.shared.getCurrentFileURL() else { return }
        let recordSettings = [AVFormatIDKey : kAudioFormatMPEG4AAC]
        try! self.audioRecorder = AVAudioRecorder(url: audioURL, settings: recordSettings)
        self.audioRecorder.delegate = self
    }
}
