import UIKit
import Lottie

class SplashScreenViewController: UIViewController {
    
    @IBOutlet weak var animatedView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let animationView = AnimationView(name: "audio_wave_animation")
        animationView.frame = CGRect(x: 0, y: 0, width: 400, height: 300)
        animationView.center = self.view.center
        //animationView.contentMode = .scaleAspectFill
        //animationView.loopMode = LottieLoopMode.loop
        self.view.addSubview(animationView)
        animationView.play()
    }
}
