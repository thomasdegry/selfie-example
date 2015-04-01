//
//  ViewController.swift
//  SelfieExample
//
//  Created by LOANER on 3/31/15.
//  Copyright (c) 2015 Thomas Degry. All rights reserved.
//

import UIKit
import Snap
import CoreGraphics
import Accelerate

class ShareViewController: UIViewController, CodeInputDelegate {
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var wrapper: UIView!
    
    var blurredBackgroundImage:UIImageView?
    var codeInputViewController:CodeInputViewController?
    var codeInputIsVisible = false

    @IBAction func allowCodeInput(sender: UIButton) {
        if self.codeInputViewController == nil {
            let codeInputVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("codeInputVC") as? CodeInputViewController
            self.codeInputViewController = codeInputVC!
            self.codeInputViewController?.view.setTranslatesAutoresizingMaskIntoConstraints(false)
            self.codeInputViewController?.delegate = self
            self.view.addSubview(self.codeInputViewController!.view)
            
            self.codeInputViewController?.view.snp_makeConstraints({ (make) -> () in
                make.width.equalTo(400)
                make.height.equalTo(500)
                make.centerX.equalTo(self.view.snp_centerX)
                make.centerY.equalTo(self.view.snp_centerY)
            })
            
            self.codeInputViewController?.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1)
            self.codeInputViewController?.view.alpha = 0.0
            
            self.codeInputViewController?.view.layer.shadowColor = UIColor.blackColor().CGColor
            self.codeInputViewController?.view.layer.shadowOffset = CGSizeMake(0, 5)
            self.codeInputViewController?.view.layer.shadowOpacity = 0.8
            self.codeInputViewController?.view.layer.shadowRadius = 5
            self.codeInputViewController?.view.layer.shouldRasterize = true
            self.codeInputViewController?.view.layer.rasterizationScale = UIScreen.mainScreen().scale
        }
        
        if self.codeInputIsVisible {
            self.hideCodeInput()
        } else {
            self.showCodeInput()
        }
        
        self.codeInputIsVisible = !self.codeInputIsVisible
    }
    
    override func viewDidLoad() {
        makeBlurredVersionOfCurrentView()
    }
    
    func hideModalWithSuccessMessage(message: String) {
        hideCodeInput()
        self.codeInputIsVisible = false
    }
    
    func showCodeInput() {
        self.codeInputViewController?.view.userInteractionEnabled = true
        
        let blurAnimation = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
        blurAnimation.toValue = 1
        blurAnimation.duration = 0.2
        self.blurredBackgroundImage!.pop_addAnimation(blurAnimation, forKey: "blur.alpha")
        
        let codeInputScale = POPSpringAnimation(propertyNamed: kPOPViewScaleXY)
        codeInputScale.toValue = NSValue(CGPoint: CGPointMake(1, 1))
        codeInputScale.springBounciness = 5.0
        codeInputScale.springSpeed = 10.0
        self.codeInputViewController!.view.pop_addAnimation(codeInputScale, forKey: "codeInput.scale")
        
        let codeInputAlpha = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
        codeInputAlpha.toValue = 1
        self.codeInputViewController!.view.pop_addAnimation(codeInputAlpha, forKey: "codeInput.alpha")
    }
    
    func hideCodeInput() {
        let blurAnimation = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
        blurAnimation.toValue = 0
        blurAnimation.duration = 0.2
        self.blurredBackgroundImage!.pop_addAnimation(blurAnimation, forKey: "blur.alpha")
        
        self.codeInputViewController?.view.userInteractionEnabled = false
        
        let codeInputScale = POPSpringAnimation(propertyNamed: kPOPViewScaleXY)
        codeInputScale.toValue = NSValue(CGPoint: CGPointMake(1.1, 1.1))
        codeInputScale.springBounciness = 5.0
        codeInputScale.springSpeed = 10.0
        self.codeInputViewController!.view.pop_addAnimation(codeInputScale, forKey: "codeInput.scale")
        
        let codeInputAlpha = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
        codeInputAlpha.toValue = 0
        self.codeInputViewController!.view.pop_addAnimation(codeInputAlpha, forKey: "codeInput.alpha")
    }
    
    func makeBlurredVersionOfCurrentView() {
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.renderInContext(UIGraphicsGetCurrentContext())
        let startImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            let resultImage = UIImageEffects.imageByApplyingBlurToImage(startImage, withRadius: 20, tintColor: UIColor(white: 0.11, alpha: 0.4), saturationDeltaFactor: 2, maskImage: nil)
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.blurredBackgroundImage = UIImageView(image: resultImage)
                self.blurredBackgroundImage!.setTranslatesAutoresizingMaskIntoConstraints(false)
                self.blurredBackgroundImage?.alpha = 0
                self.view.addSubview(self.blurredBackgroundImage!)
                
                self.blurredBackgroundImage!.snp_makeConstraints({ (make) -> () in
                    make.width.equalTo(self.view.snp_width)
                    make.height.equalTo(self.view.snp_height)
                    make.left.equalTo(0)
                    make.right.equalTo(0)
                })
            })
        })
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        let touchPoint = touches.anyObject()?.locationInView(self.view)
        let viewPoint = self.codeInputViewController?.view.convertPoint(touchPoint!, fromView: self.view)
        
        if codeInputIsVisible {
            if !self.codeInputViewController!.view.pointInside(viewPoint!, withEvent: event) {
                self.hideCodeInput()
                self.codeInputIsVisible = false
            }
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true;
    }

}

