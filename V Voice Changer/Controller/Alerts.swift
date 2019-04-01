import UIKit

final class Alerts {
    
    enum Error {
        case url
        case audioSession
        case audioRecorder
        case recording
    }
    
    static func show(error: Error, viewController: UIViewController) {
        let alert: UIAlertController!
        switch error {
        case .url:
            alert = UIAlertController(title: "File System Error", message: "The app could not access the file system to save the audio.", preferredStyle: .alert)
        case .audioSession:
            alert = UIAlertController(title: "Audio Session Error", message: "The audio session could not be activated.", preferredStyle: .alert)
        case .audioRecorder:
            alert = UIAlertController(title: "Audio Recorder Error", message: "The audio recorder could not start.", preferredStyle: .alert)
        case .recording:
            alert = UIAlertController(title: "Recording Error", message: "There was a problem while recording the audio", preferredStyle: .alert)
        }
        viewController.show(alert, sender: nil)
    }
}
