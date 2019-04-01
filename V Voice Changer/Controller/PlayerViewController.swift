import UIKit

class PlayerViewController: UIViewController {
    var recordedAudio: AudioFile?
    
    override func viewDidLoad() {
        print(recordedAudio!.name)
    }
}
