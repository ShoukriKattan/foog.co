//
//  CameraViewController.swift
//  FOOG
//
//  Created by Zafer Shaheen on 4/23/15.
//  Copyright (c) 2015 FOOG. All rights reserved.
//

import UIKit

import AVFoundation

import Parse

import ParseUI

/** Duration of transition between camera viw and taken photo view. */
let TRANSITION_DURATION = 0.2

enum CameraViewMode {
    case MealMode
    case SummaryMode
}

class CameraViewController: UIViewController {
    
    // MARK: CameraViewController
    
    /** IBOutlet to simple label UI field placed over camera view. */
    @IBOutlet weak var noteLbl: UILabel!
    
    /** IBOutlet to back button UI field. */
    @IBOutlet weak var backBtn: UIButton!
    
    /** IBOutlet to capture button UI field. */
    @IBOutlet weak var captureBtn: UIButton!
    
    /** IBOutlet to flash button UI field. */
    @IBOutlet weak var flashBtn: UIButton!
    
    /** IBOutlet to image view UI field to show taken photo. */
    @IBOutlet weak var takenPhotoIV: UIImageView!
    
    /** IBOutlet to a uiview which includes all post take photo buttons. */
    @IBOutlet weak var postButtonsView: UIView!
    
    /** IBOutlet to retake button UI field. */
    @IBOutlet weak var retakeBtn: UIButton!
    
    /** IBOutlet to note button UI field. */
    @IBOutlet weak var noteBtn: UIButton!
    
    /** IBOutlet to note button width constraint used to hide note button. */
    @IBOutlet weak var noteBtnWidthConstraint: NSLayoutConstraint!
    
    /** IBOutlet to post button UI field. */
    @IBOutlet weak var postBtn: UIButton!
    
    /** Simple white view covers the whole screen used to splash the screen when switch between camera and taken photo views. */
    @IBOutlet weak var whiteFullView: UIView!
    
    /** Reference to delegate of this camera view controller to be invoked when photo is taken and Post button is clicked. */
    weak var delegate : CameraViewDelegate?
    
    /** Posting activity indicator in view's. */
    @IBOutlet weak var postingActivityIndicator: UIActivityIndicatorView!
    
    /** Posting View. */
    @IBOutlet weak var postingView: UIView!
    
    /**
        Enumerable property which indicate mode of camera view controller.
        CameraViewMode.MealMode is default value.
    */
    var mode : CameraViewMode = CameraViewMode.MealMode
    
    /** AV Session to connect to camera device. */
    var session : AVCaptureSession!
    
    /** Reference to video device input. */
    var videoDeviceInput : AVCaptureDeviceInput!
    
    /** Still image output of AV session. */
    var stillImageOutput : AVCaptureStillImageOutput!
    
    /** User's note for this post. */
    var userNote : String = ""
    
    /** Temporary reference to used NoteViewController to access user's note after editing it. */
    var noteViewController : NoteViewController!
    
    /** Caputer Session Preview Layer. */
    var previewLayer : AVCaptureVideoPreviewLayer!
    
    /** Dismiss camera view when back button is clicked. */
    @IBAction func backBtnClicked(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            
        })
        
    }
    
    /** Toggle camera flash status when flash button is clicked. */
    @IBAction func flashBtnClicked(sender: AnyObject) {
    
        let device = self.videoDeviceInput.device
        
        if(device.hasFlash && device.lockForConfiguration(nil)) {
            // Toggle flash mode on / off
            if (device.flashMode == AVCaptureFlashMode.On) {
                device.flashMode = AVCaptureFlashMode.Off
                self.flashBtn.setImage(UIImage(named: "CameraFlashOff.png"), forState: UIControlState.Normal)
            } else {
                device.flashMode = AVCaptureFlashMode.On
                self.flashBtn.setImage(UIImage(named: "CameraFlashOn.png"), forState: UIControlState.Normal)
            }
        }
        
    }
    
    /** Take a photo when capture button is clicked. */
    @IBAction func captureBtnClicked(sender: AnyObject) {
        
        
        // Take photo.
        self.stillImageOutput.captureStillImageAsynchronouslyFromConnection(self.stillImageOutput.connectionWithMediaType(AVMediaTypeVideo), completionHandler: { (sampleBuffer : CMSampleBuffer!, error : NSError!) -> Void in
            
            if (error != nil) {
                // TODO: Handle any error.
                println("CameraViewController, captureBtnClicked, error: \(error), \(error.userInfo)")
            } else {
                // Transit view into taken photo view.
                UIView.animateWithDuration(TRANSITION_DURATION, animations: { () -> Void in
                    self.whiteFullView.alpha = 1
                    }, completion: { (isFinished: Bool) -> Void in
                        self.backBtn.hidden = true
                        self.noteLbl.hidden = true
                        self.captureBtn.hidden = true
                        self.takenPhotoIV.hidden = false
                        self.postButtonsView.hidden = false
                        self.session.stopRunning()
                        
                        // Hide white layer.
                        UIView.animateWithDuration(TRANSITION_DURATION, animations: { () -> Void in
                            self.whiteFullView.alpha = 0
                        })
                        
                        
                })
                
                var imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                self.takenPhotoIV.image = UIImage(data: imageData)
            }
            
        })
        
        
        
    }
    
    /** Ignore taken photo and back to take a new one when retake button is clicked. */
    @IBAction func retakeBtnClicked(sender: AnyObject) {
        // Re-enable camera view.
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            self.session.startRunning()
        })
        
        // Clear user's note if it is set.
        self.userNote = ""
        
        // Transit view into camera photo view.
        UIView.animateWithDuration(TRANSITION_DURATION, animations: { () -> Void in
            self.whiteFullView.alpha = 1
            }, completion: { (isFinished: Bool) -> Void in
                self.backBtn.hidden = false
                if (self.mode == CameraViewMode.MealMode) {
                    self.noteLbl.hidden = false
                }
                self.captureBtn.hidden = false
                self.takenPhotoIV.hidden = true
                self.postButtonsView.hidden = true
                
                // Hide white layer.
                UIView.animateWithDuration(TRANSITION_DURATION, animations: { () -> Void in
                    self.whiteFullView.alpha = 0
                })
                
                
        })
    }
    
    /** Show note view to add / edit user's note. */
    @IBAction func noteBtnClicked(sender: AnyObject) {
        noteViewController = NoteViewController(nibName: "NoteViewController", bundle: nil)
        noteViewController.oldNote = self.userNote
        self.presentViewController(noteViewController, animated: true, completion: nil)
    }
    
    /** Post taken meal's photo to the backend. */
    @IBAction func postBtnClicked(sender: AnyObject) {
        
        self.postingView.hidden = false
        self.postingActivityIndicator.startAnimating()
        self.postingActivityIndicator.hidden = false
        UIView.animateWithDuration(0.25, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                self.postingView.alpha = 1.0
            
            }) { (finished : Bool ) -> Void in
                // Invoke camera view delegate.
                if (self.delegate != nil) {
                    self.delegate?.cameraViewDidTakePostImage(self, image: self.takenPhotoIV.image!, note: self.userNote)
                }
        }
    }
    
    /** Posting Faild. */
    func postingFaild() {
        
        if(self.mode == CameraViewMode.MealMode){
            FoogAlert.show(FoogMessages.ErrorPostMailFail, context: self)
        } else {
            
            FoogAlert.show(FoogMessages.ErrorPostSummryCardPhotoFail, context: self)
        }
        
        self.postingView.hidden = true
        self.postingView.alpha = 0.0
        self.postingActivityIndicator.stopAnimating()
        self.postingActivityIndicator.hidden = true
    }
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hide show proper field according to camera view's mode.
        if (self.mode == CameraViewMode.MealMode) {
            // Do nothing as default mode is meal mode.
        } else if(self.mode == CameraViewMode.SummaryMode) {
            self.noteLbl.hidden = true
            self.noteBtn.hidden = true
            self.noteBtnWidthConstraint.constant = 0
        }
        
        // Aligne Retake, Note and Post buttons titles vertically with their icons.
        self.retakeBtn.alignImageAndTitleVertically()
        self.noteBtn.alignImageAndTitleVertically()
        self.postBtn.alignImageAndTitleVertically()
        
        // Initialize AV session to stream camera input to the view.
        self.session = AVCaptureSession()
        self.session.sessionPreset = AVCaptureSessionPresetPhoto
        
        let defaultDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        var error : NSError?
        self.videoDeviceInput = AVCaptureDeviceInput(device: defaultDevice, error: &error)
        
        if (self.session.canAddInput(self.videoDeviceInput)) {
            self.session.addInput(self.videoDeviceInput)
        }
        
        self.previewLayer = AVCaptureVideoPreviewLayer(session: self.session)
        self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        self.previewLayer.frame = self.view.layer.frame
        self.view.layer.insertSublayer(self.previewLayer, atIndex: 0)
        
        
        
        self.stillImageOutput = AVCaptureStillImageOutput()
        self.stillImageOutput.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
        
        if (self.session.canAddOutput(self.stillImageOutput)) {
            self.session.addOutput(self.stillImageOutput)
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            self.session.startRunning()
        })
        
        /** Hide Posting View. */
        self.postingView.hidden = true
    }
    
    /** Get user's note editted by NoteViewController. */
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if (self.noteViewController != nil) {
            
            self.userNote = self.noteViewController.noteTV.text
            self.noteViewController = nil
        }
        
    }
    
    /** Prevent landscape orientation. */
    override func shouldAutorotate() -> Bool {
        if (UIInterfaceOrientationIsPortrait(UIApplication.sharedApplication().statusBarOrientation)) {
            return false
        } else {
            return true
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillLayoutSubviews() {
        self.previewLayer.frame = self.view.bounds;
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        //Hide posting View
        self.postingView.hidden = true
        self.postingView.alpha = 0.0
        self.postingActivityIndicator.stopAnimating()
        self.postingActivityIndicator.hidden = true
        
        //Stop the session
        self.session.stopRunning()
    }
    
}

/** Delegate for CameraViewController which responsible for implement functionality of click on "Post" button. */
protocol CameraViewDelegate : class {
    
    /** 
        This method is invoked when user take a photo and click "Post" button with taken photo and user's note parameter.
        This method should hide presented camera view controller. 
    */
    func cameraViewDidTakePostImage(cameraViewController : CameraViewController, image : UIImage, note : String?)
    
}
