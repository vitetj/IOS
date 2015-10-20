//
//  ViewController.swift
//  Photo Share
//
//  Created by MacBook FV iMAGINATION on 27/10/14.
//  Copyright (c) 2014 FV iMAGINATION. All rights reserved.
//

import UIKit
import Social
import MessageUI


/* GLOBAL VARIABLES & VIEWS */
var pickedImage: UIImage?


class ViewController: UIViewController,
UINavigationControllerDelegate,
UIImagePickerControllerDelegate
{

    /* Hide the StatusBar =======*/
override func prefersStatusBarHidden() -> Bool {
        return true
}
func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        UIApplication.sharedApplication().statusBarHidden = true
}
    
   
    
override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
}

/* Take a Photo from Camera =========*/
@IBAction func camButt(sender: AnyObject) {
    if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
        var imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.Camera;
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
}
    
/* Pick an image from Photo Library ============*/
@IBAction func libraryButt(sender: AnyObject) {
    if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
        var imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary;
            
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
}
    
    
/* ImagePicker DELEGATE ===========*/
func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: NSDictionary!) {
        
        pickedImage = image
        self.dismissViewControllerAnimated(false, completion: nil)
        
        // go to Crop Image Controller to apply text to the picked image
        goToPhotoShareController()
}
    
    
func goToPhotoShareController() {
        let myVC = self.storyboard?.instantiateViewControllerWithIdentifier("PhotoShareController") as PhotoShareController
        self.presentViewController(myVC, animated: true, completion: nil)
    }

    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
}


} /* END =======*/










/* ====================================================================
=================  PHOTO SHARE CLASS & CODE   =========================
======================================================================*/

class PhotoShareController: UIViewController,
    MFMessageComposeViewControllerDelegate,
    MFMailComposeViewControllerDelegate,
    UIDocumentInteractionControllerDelegate
{

      /* Views */
    @IBOutlet weak var imageToBeShared: UIImageView!
    var docIntController: UIDocumentInteractionController?
    
    @IBOutlet weak var sharingScrollView: UIScrollView!
    
    
    @IBOutlet weak var prepareForInstagramView: UIView!
    @IBOutlet weak var cropView: UIView!
    @IBOutlet weak var croppedImage: UIImageView!

    
    
/* Hide the StatusBar =======*/
override func prefersStatusBarHidden() -> Bool {
        return true
}
    
override func viewDidLoad() {
        super.viewDidLoad()

    // Move the Prepare For Instagram View out of the screen
    prepareForInstagramView.frame.origin.y = self.view.frame.size.height
    
    // Get image from previous Controller
    imageToBeShared.image = pickedImage

    sharingScrollView.contentSize = CGSizeMake(76*8, 70)
}
    

    
/*======================= SHARING BUTTONS ==============================
========================================================================*/
    
    // You can edit the sharing message and subject here:
    var subjectText = "My Photo"
    var messageText = "Hi there, just sharing a nice photo!"
    
    
    
/* SAVE TO PHOTO LIBRARY ========================================*/
@IBAction func saveToLibraryButt(sender: AnyObject) {
    
    UIImageWriteToSavedPhotosAlbum(imageToBeShared.image, nil,nil, nil)
        
    let alert: UIAlertView = UIAlertView(title: "Image saved to Photo library", message: nil, delegate: self, cancelButtonTitle: "OK")
        alert.show()
}
    
    
    
/* TWITTER Sharing ==============================================*/
@IBAction func twitterButt(sender: AnyObject) {
    if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter) {
        var twSheet = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
        twSheet.setInitialText(messageText)
        twSheet.addImage(imageToBeShared.image)
        self.presentViewController(twSheet, animated: true, completion: nil)
        } else {
        var alert: UIAlertView = UIAlertView(title: "Twitter", message: "Please login to your Twitter account in Settings", delegate: self, cancelButtonTitle: "OK")
        alert.show()
        }
}
    
    
/* FACEBOOK Sharing ===========================================*/
@IBAction func facebookButt(sender: AnyObject) {
    if SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook) {
        var fbSheet = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
        fbSheet.setInitialText(messageText)
        fbSheet.addImage(imageToBeShared.image)
        self.presentViewController(fbSheet, animated: true, completion: nil)
        } else {
        var alert: UIAlertView = UIAlertView(title: "Facebook", message: "Please login to your Facebook account in Settings", delegate: self, cancelButtonTitle: "OK")
        alert.show()
        }
}
    
    
/* MAIL Sharing ====================================================*/
@IBAction func mailButt(sender: AnyObject) {
        var mailComposer: MFMailComposeViewController = MFMailComposeViewController()
        mailComposer.mailComposeDelegate = self
        mailComposer.setSubject(subjectText)
        mailComposer.setMessageBody(messageText, isHTML: true)
        // Prepares the image to be shared by Email
        var imageData = UIImageJPEGRepresentation(imageToBeShared.image, 1.0)
        mailComposer.addAttachmentData(imageData, mimeType: "image/png", fileName: "MyPhoto.png")
        
        self.presentViewController(mailComposer, animated: true, completion: nil)
    }
// Email results ================
func mailComposeController(controller:MFMailComposeViewController, didFinishWithResult result:MFMailComposeResult, error:NSError) {
        switch result.value {
        case MFMailComposeResultCancelled.value:
            NSLog("Mail cancelled")
        case MFMailComposeResultSaved.value:
            NSLog("Mail saved")
        case MFMailComposeResultSent.value:
            NSLog("Mail sent")
        case MFMailComposeResultFailed.value:
            NSLog("Mail sent failure: %@", [error.localizedDescription])
        default:
            break
        }
        self.dismissViewControllerAnimated(false, completion: nil)
}
    
    
    
    
/* MESSAGE Sharing ===============================================*/
@IBAction func messageButt(sender: AnyObject) {
/* =================
    NOTE: The following methods work only on real device, not iOS Simulator!
=================*/
        var messageComposer: MFMessageComposeViewController = MFMessageComposeViewController()
        messageComposer.messageComposeDelegate = self
        messageComposer.subject = subjectText
        
        // Check if the device can send MMS messages
        if MFMessageComposeViewController.respondsToSelector("canSendAttachments") &&
            MFMessageComposeViewController.canSendAttachments() {
            var attachmentData: NSData = UIImageJPEGRepresentation(imageToBeShared.image, 1.0)
            messageComposer.addAttachmentData(attachmentData, typeIdentifier: "kUTTypeMessage", filename: "myPhoto.jpg")
        } else {
            var alert:UIAlertView = UIAlertView(title: "QuickTxt", message: "Sorry, your device doesn't support Messages", delegate: self, cancelButtonTitle: "OK")
        }
        
        self.presentViewController(messageComposer, animated: true, completion: nil)
}
    // Delegate
func messageComposeViewController(controller: MFMessageComposeViewController!, didFinishWithResult result: MessageComposeResult) {
        self.dismissViewControllerAnimated(true, completion: nil)
}
    
    
    
    
    
/* INSTAGRAM Sharing ============================================*/
@IBAction func instagramButt(sender: AnyObject) {
    // Show the view to crop your image
    UIView.animateWithDuration(0.2, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: {
    self.prepareForInstagramView.frame.origin.y = 0
    }, completion: { (finished: Bool) in
        self.croppedImage.image = self.imageToBeShared.image
    });
}
    
@IBAction func dismissButt(sender: AnyObject) {
    // Hide the view
    UIView.animateWithDuration(0.2, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: {
    self.prepareForInstagramView.frame.origin.y = self.view.frame.size.height
    }, completion: { (finished: Bool) in
    });
}
    // Image that will be rendered into a square frame
    var imageForInstagram: UIImage?
    
/* CROP A SQUARE IMAGE FOR INSTAGRAM */
func cropFinalImage() {
    var rect:CGRect = cropView.bounds
    UIGraphicsBeginImageContextWithOptions(rect.size, true, 0.0)
    cropView.drawViewHierarchyInRect(cropView.bounds, afterScreenUpdates: false)
    imageForInstagram = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
}
    
@IBAction func openInstagramButt(sender: AnyObject) {
    
    cropFinalImage()
    
/* =================
    NOTE: The following methods work only on real device, and you should have Instagram already installed into your device!
=================*/
    var instagramURL: NSURL = NSURL(string: "instagram://app")!
    if UIApplication.sharedApplication().canOpenURL(instagramURL) {
        
        // Hooks the image to Instagram
        var jpgPath = NSHomeDirectory().stringByAppendingPathComponent("Documents/image.igo")
        UIImageJPEGRepresentation(imageForInstagram, 1.0).writeToFile(jpgPath, atomically: true)
        var imageURL:NSURL = NSURL(fileURLWithPath: jpgPath)!
        
        docIntController = UIDocumentInteractionController(URL: imageURL)
        docIntController?.UTI = "com.instagram.exclusivegram"
        docIntController?.delegate = self
        docIntController?.presentOpenInMenuFromRect(CGRectZero, inView: self.view, animated: true)
        
    } else {
    var alert:UIAlertView = UIAlertView(title: "QuickTxt",
    message: "Instagram not found, please download it on the App Store", delegate: self, cancelButtonTitle: "OK")
    alert.show()
    }

}
/* PINCH GESTURES To zoom Image =========== */
@IBAction func scaleImage(sender: UIPinchGestureRecognizer) {
    sender.view?.transform = CGAffineTransformScale(sender.view!.transform, sender.scale, sender.scale)
    sender.scale = 1
}
    
/* PAN GESTURE to move Image ==============*/
@IBAction func moveImage(sender: UIPanGestureRecognizer) {
    var translation: CGPoint =  sender.translationInView(self.view)
    sender.view?.center = CGPointMake(sender.view!.center.x +  translation.x, sender.view!.center.y + translation.y)
    sender.setTranslation(CGPointMake(0, 0), inView: self.view)
}

// Set cropView background color
@IBAction func bkgColorButt(sender: AnyObject) {
    cropView.backgroundColor = sender.backgroundColor
}
    
    
    
    
    
/* WHATS APP Sharing ==============================================*/
    @IBAction func whatsAppButt(sender: AnyObject) {
/* =================
    NOTE: The following methods work only on real device, not iOS Simulator, and you should have WhatsApp already installed into your device!
=================*/
        var whatsAppURL: NSURL = NSURL(string: "whatsapp://app")!
        if UIApplication.sharedApplication().canOpenURL(whatsAppURL) {
            
            var jpgPath = NSHomeDirectory().stringByAppendingPathComponent("Documents/image.wai")
            UIImageJPEGRepresentation(imageToBeShared.image, 1.0).writeToFile(jpgPath, atomically: true)
            var imageURL:NSURL = NSURL(fileURLWithPath: jpgPath)!
            
            docIntController = UIDocumentInteractionController(URL: imageURL)
            docIntController?.UTI = "net.whatsapp.image"
            docIntController?.delegate = self
            docIntController?.presentOpenInMenuFromRect(CGRectZero, inView: self.view, animated: true)
            
        } else {
            var alert:UIAlertView = UIAlertView(title: "QuickTxt",
                message: "WhatsApp not found, please download it on the App Store", delegate: self, cancelButtonTitle: "OK")
            alert.show()
        }
        
    }
    
    
    
    
/* OTHER APPS Sharing =======================================*/
@IBAction func otherAppsButt(sender: AnyObject) {
/* =================
    NOTE: The following methods work only on real device, not iOS Simulator, and you should have apps like  iPhoto, PicLab, etc. already installed into your device!
=================*/
        
        println("This code works fine only on REAL DEVICE. Please test it on iPhone!")
        
        docIntController?.delegate = self
        
        //Saves the Image to default device Directory
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        let savedImagePath:String = paths.stringByAppendingString("/QuickTxt Image.jpg")
        var image = imageToBeShared
        var imageData: NSData = UIImageJPEGRepresentation(imageToBeShared.image, 1.0)
        imageData.writeToFile(savedImagePath, atomically: false)
        
        //Load the Image Path
        var getImagePath = paths.stringByAppendingString("/QuickTxt Image.jpg")
        var tempImage:UIImage = UIImage(contentsOfFile: getImagePath)!
        println("\(tempImage)")
        
        // Create the URL path to the Image to be saved
        var fileURL: NSURL = NSURL.fileURLWithPath(getImagePath)!
        
        // Open the Document Interaction controller for Sharing options
        docIntController = UIDocumentInteractionController(URL: fileURL)
        docIntController?.presentOpenInMenuFromRect(CGRectZero, inView: self.view, animated: true)
    }
    
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
}
    
} /* END PHOTO SHARE CONTROLLER CLASS ===========================================*/
