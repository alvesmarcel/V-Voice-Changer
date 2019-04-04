import UIKit
import Lottie

class SplashScreenViewController: UIViewController {
    
    @IBOutlet weak var animationView: AnimationView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        animationView.animation = Animation.named("audio_wave_animation")
        animationView.animationSpeed = 0.6
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //animationView.loopMode = LottieLoopMode.loop
        animationView.play { [weak self] (success) in
            DispatchQueue.main.async {
                guard let playerVC = self?.storyboard?.instantiateViewController(withIdentifier: "NavigationController") as? UINavigationController else {
                    print("PlayerViewController could not be instantiated")
                    return
                }
                self?.show(playerVC, sender: nil)
                //self?.transition(from: self!, to: playerVC, duration: 3.0, options: .transitionCrossDissolve, animations: nil, completion: nil)
            }
        }
        
        
    }
}
