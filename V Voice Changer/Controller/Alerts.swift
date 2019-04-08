import UIKit

final class Alerts {
    
    enum Error {
        case url
        case audioSession
        case audioRecorder
        case recording
        case audioEngine
    }
    
    static func presentPermissionDeniedAlert(sender: UIViewController) {
        let alertController = UIAlertController (title: "Permission Denied", message: "The application does not have permission to use the microphone. Go to Settings to allow microphone usage.", preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    print("Settings opened: \(success)") // Prints true
                })
            }
        }
        alertController.addAction(settingsAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alertController.addAction(cancelAction)
        sender.present(alertController, animated: true, completion: nil)
    }
    
    static func present(error: Error, sender: UIViewController) {
        let alert: UIAlertController!
        switch error {
        case .url:
            alert = UIAlertController(title: "File System Error", message: "The app could not access the file system to save the audio.", preferredStyle: .alert)
        case .audioSession:
            alert = UIAlertController(title: "Audio Session Error", message: "The audio session could not be activated.", preferredStyle: .alert)
        case .audioRecorder:
            alert = UIAlertController(title: "Audio Recorder Error", message: "The audio recorder could not be started.", preferredStyle: .alert)
        case .recording:
            alert = UIAlertController(title: "Recording Error", message: "There was a problem with audio recording", preferredStyle: .alert)
        case .audioEngine:
            alert = UIAlertController(title: "Audio Engine Error", message: "The audio engine could not be started.", preferredStyle: .alert)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alert.addAction(cancelAction)
        sender.present(alert, animated: true, completion: nil)
    }
}
