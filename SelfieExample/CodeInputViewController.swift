//
//  CodeInputViewController.swift
//  SelfieExample
//
//  Created by LOANER on 3/31/15.
//  Copyright (c) 2015 Thomas Degry. All rights reserved.
//

import UIKit
import Snap

protocol CodeInputDelegate {
    func hideModalWithSuccessMessage(message:String)
}

class CodeInputViewController: UIViewController {
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var doneButton: UIButton! {
        didSet {
            let backgroundImage = UIImage(named: "accept")
            let backgroundImageIV = UIImageView(image: backgroundImage)
            backgroundImageIV.setTranslatesAutoresizingMaskIntoConstraints(false)
            backgroundImageIV.contentMode = UIViewContentMode.Center
            self.doneButton.addSubview(backgroundImageIV)
            
            backgroundImageIV.snp_makeConstraints { (make) -> () in
                make.width.equalTo(self.doneButton.snp_width)
                make.height.equalTo(self.doneButton.snp_height)
                make.top.equalTo(0)
                make.left.equalTo(0)
            }
        }
    }
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var yourCodeLabel: UILabel!
    @IBOutlet weak var codeLabel: UILabel!
    @IBOutlet weak var yourCodeLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var standardViewLeftConstraint: NSLayoutConstraint!
    
    var codeLabelIsDown = true
    var isShowingError = false
    var delegate:CodeInputDelegate?
    
    override func viewDidLoad() {
        let attributedString = self.yourCodeLabel.attributedText as NSMutableAttributedString
        attributedString.addAttribute(NSKernAttributeName, value: 2.0, range: NSMakeRange(0, attributedString.length))
        yourCodeLabel.attributedText = attributedString
        
        // Hide the spinner
        self.spinner.stopAnimating()
        
        // Reset the label
        self.codeLabel.text = ""
        self.yourCodeLabelTopConstraint.constant = 58
        self.view.layoutIfNeeded()
    }
    
    @IBAction func buttonTapped(sender: UIButton) {
        if countElements(self.codeLabel.text!) < 5 {
            if isShowingError {
                self.isShowingError = false
                switchToNormalView()
            }
            
            self.codeLabel.text = self.codeLabel.text! + sender.titleLabel!.text!
            self.checkCodeLengthForTopConstraint()
        }
    }

    @IBAction func deleteTapped(sender: UIButton) {
        if self.codeLabel.text != "" {
            self.codeLabel.text = self.codeLabel.text!.substringToIndex(self.codeLabel.text!.endIndex.predecessor())
            self.checkCodeLengthForTopConstraint()
        }
    }
    
    @IBAction func enter(sender: UIButton) {
        let attributedString = NSMutableAttributedString(string: "VERIFYING")
        attributedString.addAttribute(NSKernAttributeName, value: 2.0, range: NSMakeRange(0, attributedString.length))
        yourCodeLabel.attributedText = attributedString
        
        self.spinner.startAnimating()
        self.doneButton.hidden = true
        
        handleInput()
    }
    
    func handleInput() {
        if self.codeLabel.text == "15963" {
            // Code is correct
            var timer = NSTimer.scheduledTimerWithTimeInterval(1.3, target: self, selector: Selector("dismissCodeInput"), userInfo: nil, repeats: false)
        } else {
            // Code is not correct
            var timer = NSTimer.scheduledTimerWithTimeInterval(1.3, target: self, selector: Selector("tmpFakeError"), userInfo: nil, repeats: false)
        }
    }
    
    func tmpFakeError() {
        self.isShowingError = true
        
        self.spinner.stopAnimating()
        self.doneButton.hidden = false
        self.codeLabel.text = ""
        self.checkCodeLengthForTopConstraint()
        
        let attributedString = NSMutableAttributedString(string: "ENTER YOUR CODE")
        attributedString.addAttribute(NSKernAttributeName, value: 2.0, range: NSMakeRange(0, attributedString.length))
        yourCodeLabel.attributedText = attributedString
        
        self.switchToErrorView()
    }
    
    func dismissCodeInput() {
        self.spinner.stopAnimating()
        self.doneButton.hidden = false
        self.codeLabel.text = ""
        self.checkCodeLengthForTopConstraint()
        
        let attributedString = NSMutableAttributedString(string: "ENTER YOUR CODE")
        attributedString.addAttribute(NSKernAttributeName, value: 2.0, range: NSMakeRange(0, attributedString.length))
        yourCodeLabel.attributedText = attributedString
        
        self.delegate?.hideModalWithSuccessMessage("We emailed the selfie to your email address!")
    }
    
    func checkCodeLengthForTopConstraint() {
        if self.codeLabel.text == "" {
            self.deleteButton.hidden = true
            
            let animation = POPSpringAnimation(propertyNamed: kPOPLayoutConstraintConstant)
            animation.toValue = 58
            animation.springBounciness = 12
            animation.springSpeed = 10
            self.yourCodeLabelTopConstraint.pop_addAnimation(animation, forKey: "yourlabel.translate.y")
            
            self.codeLabelIsDown = true
        } else {
            if codeLabelIsDown {
                self.deleteButton.hidden = false
                
                let animation = POPSpringAnimation(propertyNamed: kPOPLayoutConstraintConstant)
                animation.toValue = 41
                animation.springBounciness = 12
                animation.springSpeed = 10
                self.yourCodeLabelTopConstraint.pop_addAnimation(animation, forKey: "yourlabel.translate.y")
                
                self.codeLabelIsDown = false
            }
        }
    }
    
    func switchToErrorView() {
        let animation = POPSpringAnimation(propertyNamed: kPOPLayoutConstraintConstant)
        animation.toValue = -self.view.frame.width
        animation.springBounciness = 8
        animation.springSpeed = 5
        self.standardViewLeftConstraint.pop_addAnimation(animation, forKey: "normalView.translate.x")
    }
    
    func switchToNormalView() {
        let animation = POPSpringAnimation(propertyNamed: kPOPLayoutConstraintConstant)
        animation.toValue = 0
        animation.springBounciness = 5
        animation.springSpeed = 10
        self.standardViewLeftConstraint.pop_addAnimation(animation, forKey: "normalView.translate.x")
    }

}
