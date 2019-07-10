import UIKit

class AnimatedViewController: ImageSourceViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageSourceView.isAnimationEnabled = true
    }
}
