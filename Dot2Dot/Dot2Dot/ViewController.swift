//
//  ViewController.swift
//  Dot2Dot
//
//  Created by MacBook FV iMAGINATION on 13/10/14.
//  Copyright (c) 2014 FV iMAGINATION. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation
import GameKit
import iAd
import Social


/* Global Variables */
var score: Int = 0
var bestScore: Int = 0
var bestScoreString: String = ""

var timerDots: NSTimer?

var tapsCountLeft: Int = 0
var tapsCountRight: Int = 0

var volumeBool: Bool = true

var audioPlayer = AVAudioPlayer()

// For iAd Network
var _bannerIsVisible: Bool = false
var _adBanner: ADBannerView?



/*=========================================================
=============== HOME VIEW CONTROLLER =================
=========================================================*/
class Home: UIViewController  {
    
    
override func prefersStatusBarHidden() -> Bool {
        return true
}
    
override func viewDidLoad() {
        super.viewDidLoad()
    if volumeBool {
        volumeOut.setTitle("SOUND ON", forState: UIControlState.Normal)
    } else {
        volumeOut.setTitle("SOUND OFF", forState: UIControlState.Normal)
    }
 
    
    // Init iAd banner ======
    _adBanner = ADBannerView(frame: CGRectMake(0, self.view.frame.size.height-50, 320, 50) )
    _adBanner?.backgroundColor = UIColor.clearColor()
    self.view.addSubview(_adBanner!)
}
    
    
    
/* Volume Button ====== */
    @IBOutlet weak var volumeOut: UIButton!
@IBAction func volButt(sender: AnyObject) {
    volumeBool = !volumeBool
    
    if volumeBool {
        volumeOut.setTitle("SOUND ON", forState: UIControlState.Normal)
    } else {
        volumeOut.setTitle("SOUND OFF", forState: UIControlState.Normal)
    }
    
}

/* iAD DELEGATES ======================================*/
func bannerViewAdLoad(banner: ADBannerView!) {
        if !_bannerIsVisible {
        if _adBanner?.superview == nil {
                self.view.addSubview(_adBanner!)
        }
    }
        UIView.beginAnimations("animateAdBannerOn", context: nil)
        banner.alpha = 1.0
        UIView.commitAnimations()
        
        _bannerIsVisible = true
}
    
func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
        print("Failed to retrieve Ad")
        
        if _bannerIsVisible {
            UIView.beginAnimations("animateAdBannerOff", context: nil)
            banner.alpha = 0.0
            UIView.commitAnimations()
            
            _bannerIsVisible = false
        }
}

    
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
  }
    
    
} /* ======  END HOME ViewController =======================*/







/*=========================================================
=============== VIEW CONTROLLER ==========================
=========================================================*/
class ViewController: UIViewController {
    
    /* Double Dot ImageViews */
    @IBOutlet weak var doubleDotLeft: UIImageView!
    @IBOutlet weak var doubleDotRight: UIImageView!
    
    /* Score Label */
    @IBOutlet weak var scoreLabel: UILabel!

 
    
override func prefersStatusBarHidden() -> Bool {
        return true
}

    
/* viewDidLoad ==========*/
override func viewDidLoad() {
        super.viewDidLoad()

    // Load the Best Score
    bestScore = NSUserDefaults.standardUserDefaults().integerForKey("bestScore")
    
    
    // Reset game variables
    score = 0
    scoreLabel.text = "0"
    tapsCountLeft = 0
    tapsCountRight = 0
    
    // Update game timer for spawning dots
    updateTimer()

    // Init iAd banner ======
    _adBanner = ADBannerView(frame: CGRectMake(0, self.view.frame.size.height-50, 320, 50) )
    _adBanner?.backgroundColor = UIColor.clearColor()
    self.view.addSubview(_adBanner!)
    
}

   
func updateTimer() {
    if score < 3 {
    timerDots = NSTimer.scheduledTimerWithTimeInterval(1.5, target: self, selector: "fireDot", userInfo: nil, repeats: true)
    
    // Dots get generated a bit faster than before after score reaches 3
    } else if score == 3 {
        timerDots?.invalidate()
        timerDots = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "fireDot", userInfo: nil, repeats: true)
    
    // Dots get generated even faster than before after score reaches 12
    } else if score == 12 {
        timerDots?.invalidate()
        timerDots = NSTimer.scheduledTimerWithTimeInterval(0.9, target: self, selector: "fireDot", userInfo: nil, repeats: true)
    }
    
}

    
 
/* LEFT & RIGHT BUTTONS =============*/
    @IBOutlet weak var buttLeftOut: UIButton!
    
@IBAction func buttLeft(sender: AnyObject) {
    tapsCountLeft++

    UIView.animateWithDuration(0.1, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: {
        if tapsCountLeft == 0 {
        self.doubleDotLeft.transform = CGAffineTransformRotate(self.doubleDotLeft.transform, 0)
        } else {
        self.doubleDotLeft.transform = CGAffineTransformRotate(self.doubleDotLeft.transform, CGFloat (M_PI) )
        }
        }, completion: { (finished: Bool) in
            if tapsCountLeft > 1 {
                tapsCountLeft = 0
            }
            print("tapsCountLEFT: \(tapsCountLeft)")
    })
    
}
    
    
    @IBOutlet weak var buttRightOut: UIButton!
@IBAction func buttRight(sender: AnyObject) {
    tapsCountRight++
    
    UIView.animateWithDuration(0.1, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: {
        if tapsCountRight == 0 {
            self.doubleDotRight.transform = CGAffineTransformRotate(self.doubleDotRight.transform, 0)
        } else {
            self.doubleDotRight.transform = CGAffineTransformRotate(self.doubleDotRight.transform, CGFloat (M_PI) )
        }
        }, completion: { (finished: Bool) in
            if tapsCountRight > 1 {
                tapsCountRight = 0
            }
            print("tapsCountRIGHT: \(tapsCountRight)")
    })
    
}
    
    
    
    
    var dotsArray: NSArray = ["blueDot", "purpleDot"]

    
/* FIRE DOT METHOD ================== */
func fireDot() {
    
    // Spawn a random Dot
    let randomDotLeft = Int(arc4random() % 2)
    let randomDotRight = Int(arc4random() % 2)
    print("rndLeft: \(randomDotLeft)" )
    print("rndRight: \(randomDotRight)" )
    
    
    var dotLeft:UIImageView = UIImageView(image: UIImage(named: ""))
    var dotRight:UIImageView = UIImageView(image: UIImage(named: ""))
    
    if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
        // iPhone
        dotLeft.frame = CGRectMake(0, 0, 18, 18)
        dotRight.frame = CGRectMake(0, 0, 18, 18)
    } else {
        // iPad
        dotLeft.frame =  CGRectMake(0, 0, 22, 22)
        dotRight.frame =  CGRectMake(0, 0, 22, 22)
    }
    
    
    // Generate Dot LEFT
    dotLeft.center = CGPointMake( CGFloat(doubleDotLeft.frame.origin.x + doubleDotLeft.frame.size.width/2), 0)
    dotLeft.image = UIImage(named: "\(dotsArray.objectAtIndex(randomDotLeft))" )
    dotLeft.tag = randomDotLeft
    self.view.addSubview(dotLeft)
    
    // Generate Dot RIGHT
    dotRight.center = CGPointMake( CGFloat(doubleDotRight.frame.origin.x + doubleDotRight.frame.size.width/2), 0)
    dotRight.image = UIImage(named: "\(dotsArray.objectAtIndex(randomDotRight))" )
    dotRight.tag = randomDotRight
    self.view.addSubview(dotRight)
    
    
    // Bring the doubleDot images on the Front
    self.view.bringSubviewToFront(doubleDotLeft)
    self.view.bringSubviewToFront(doubleDotRight)
    
    playSpawnedDot()
    
    
    // Update timer that fires Dots, accordingly to the reached score
    if score == 3 {
    updateTimer()
    } else if score == 12 {
    updateTimer()
    }

    
    // Animate Dots making them falling down from the top
    UIView.animateWithDuration(1.5, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            //iPhone
            dotLeft.frame.origin.y = 332
            dotRight.frame.origin.y = 332
        } else {
        // iPad
            dotLeft.frame.origin.y = 588
            dotRight.frame.origin.y = 588
        }
        
        
        // Dot Animation Ends...
        }, completion: { (finished: Bool) in
            
            dotLeft.removeFromSuperview()
            dotRight.removeFromSuperview()

        // Add a point to the Score if circles position anmd colored dot match the same values
        if randomDotLeft == tapsCountLeft &&
            randomDotRight == tapsCountRight {
            score++
            self.scoreLabel.text = "\(score)"
            
            
        // End the round and go to GameOver controller
        } else {
            
            // Update the Best Score
            if bestScore < score {
                bestScore = score
             //   bestScoreString = "BEST SCORE: \(score)"
                
                //Save the BestScore
                NSUserDefaults.standardUserDefaults().setInteger(bestScore, forKey: "bestScore")
            } else {
             //   bestScoreString = "BEST SCORE: \(bestScore)"
            }
            
            // Play sound for Game Over
            self.playGameOver()
            
            
            // Stop the timerDots
            timerDots?.invalidate()
            self.view.layer.removeAllAnimations()
            
            let goVC = self.storyboard?.instantiateViewControllerWithIdentifier("GameOver") as! GameOver
            self.presentViewController(goVC, animated: true, completion: nil)
            }
            
    }) // END of animation's completion ===============
    
}
    

    
    

/* ===== Play SOUNDS ===============  */
func playGameOver() {
    var alertSound: NSURL = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("gameOver", ofType: "mp3")!)
    var error:NSError?
    do {
        audioPlayer = try AVAudioPlayer(contentsOfURL: alertSound)
    } catch var error1 as NSError {
        error = error1
     //   audioPlayer = nil
    }
    audioPlayer.prepareToPlay()
    
    if volumeBool {
        audioPlayer.play()
    }
}
    
func playSpawnedDot() {
    var alertSound: NSURL = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("spawnDot", ofType: "mp3")!)
    var error:NSError?
    do {
        audioPlayer = try AVAudioPlayer(contentsOfURL: alertSound)
    } catch var error1 as NSError {
        error = error1
    //    audioPlayer = nil
    }
    audioPlayer.prepareToPlay()
        
    if volumeBool {
        audioPlayer.play()
    }
}
    
    
    
/* iAD DELEGATES ======================================*/
func bannerViewAdLoad(banner: ADBannerView!) {
        if !_bannerIsVisible {
            if _adBanner?.superview == nil {
                self.view.addSubview(_adBanner!)
            }
        }
        UIView.beginAnimations("animateAdBannerOn", context: nil)
        banner.alpha = 1.0
        UIView.commitAnimations()
        
        _bannerIsVisible = true
}
    
func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
        print("Failed to retrieve Ad")
        
        if _bannerIsVisible {
            UIView.beginAnimations("animateAdBannerOff", context: nil)
            banner.alpha = 0.0
            UIView.commitAnimations()
            
            _bannerIsVisible = false
        }
}

    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
}


} /* ======  END ViewController =======================*/






/*=========================================================
=============== GAMEOVER VIEW CONTROLLER =================
=========================================================*/
class GameOver: UIViewController {
    
    /* Views */
    @IBOutlet weak var scoreLabelGO: UILabel!
    @IBOutlet weak var bestScoreLabelGO: UILabel!
    


override func prefersStatusBarHidden() -> Bool {
        return true
}
    
override func viewDidLoad() {
    super.viewDidLoad()
    
    // Set volume Button icon
    if volumeBool {
        volumeOut.setTitle("SOUND ON", forState: UIControlState.Normal)
    } else {
        volumeOut.setTitle("SOUND OFF", forState: UIControlState.Normal)
    }
    
    scoreLabelGO.text = "SCORE: \(score)"
    bestScoreLabelGO.text = "BEST SCORE: \(bestScore)"
    
    // Init iAd banner ======
    _adBanner = ADBannerView(frame: CGRectMake(0, self.view.frame.size.height-50, 320, 50) )
    _adBanner?.backgroundColor = UIColor.clearColor()
    self.view.addSubview(_adBanner!)
}
   
    
    
/* VOLUME BUTTON =============*/
    @IBOutlet weak var volumeOut: UIButton!
@IBAction func volumeButt(sender: AnyObject) {
    volumeBool = !volumeBool
    
    if volumeBool {
        volumeOut.setTitle("SOUND ON", forState: UIControlState.Normal)
    } else {
        volumeOut.setTitle("SOUND OFF", forState: UIControlState.Normal)
    }
}
    
    // App icon that will be shared on FB & TW together with the message
    @IBOutlet weak var shareImg: UIImageView!
    
/* FACEBOOK BUTTON =============*/
@IBAction func facebookButt(sender: AnyObject) {
    if SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook) {
        let fbSheet = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
        fbSheet.setInitialText("My Best Score on Dot2Dot is \(bestScore)!")
        fbSheet.addImage(shareImg.image)
        self.presentViewController(fbSheet, animated: true, completion: nil)
    } else {
        let alert: UIAlertView = UIAlertView(title: "Facebook", message: "Please login to your Facebook account in Settings", delegate: self, cancelButtonTitle: "OK")
        alert.show()
    }
    
}
/* TWITTER BUTTON =============*/
@IBAction func twitterButt(sender: AnyObject) {
    if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter) {
        let twSheet = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
        twSheet.setInitialText("My Best Score on Dot2Dot is \(bestScore)!")
        twSheet.addImage(shareImg.image)
        self.presentViewController(twSheet, animated: true, completion: nil)
    } else {
        let alert: UIAlertView = UIAlertView(title: "Twitter", message: "Please login to your Twitter account in Settings", delegate: self, cancelButtonTitle: "OK")
        alert.show()
    }
}
    
    
    
/* iAD DELEGATES ======================================*/
func bannerViewAdLoad(banner: ADBannerView!) {
        if !_bannerIsVisible {
            if _adBanner?.superview == nil {
                self.view.addSubview(_adBanner!)
            }
        }
        UIView.beginAnimations("animateAdBannerOn", context: nil)
        banner.alpha = 1.0
        UIView.commitAnimations()
        
        _bannerIsVisible = true
}
    
func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
        print("Failed to retrieve Ad")
        
        if _bannerIsVisible {
            UIView.beginAnimations("animateAdBannerOff", context: nil)
            banner.alpha = 0.0
            UIView.commitAnimations()
            
            _bannerIsVisible = false
        }
}
    
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
}
    
} /* ======= END GameOver Controller ==================*/



