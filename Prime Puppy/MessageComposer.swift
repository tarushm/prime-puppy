//
//  MessageComposer.swift
//  Prime Puppy
//
//  Created by Tarush Mohanti on 11/12/16.
//  Copyright © 2016 tarush. All rights reserved.
//

// Much help from https://www.andrewcbancroft.com/, an iOS development blog


import Foundation
import MessageUI

// let textMessageRecipients = ["1-510-449-2390"] // for pre-populating the recipients list (optional, depending on your needs)

class MessageComposer: NSObject, MFMessageComposeViewControllerDelegate {
    
    // A wrapper function to indicate whether or not a text message can be sent from the user's device
    func canSendText() -> Bool {
        return MFMessageComposeViewController.canSendText()
    }
    
    // Configures and returns a MFMessageComposeViewController instance
    func configuredMessageComposeViewController() -> MFMessageComposeViewController {
        let messageComposeVC = MFMessageComposeViewController()
        messageComposeVC.messageComposeDelegate = self  //  Make sure to set this property to self, so that the controller can be dismissed!
        //messageComposeVC.recipients = textMessageRecipients
        let highScoreObject = UserDefaults.standard.object(forKey: "highScore")
        let nObject = UserDefaults.standard.object(forKey: "n")
        let eObject = UserDefaults.standard.object(forKey: "e")
        let p1Object = UserDefaults.standard.object(forKey: "prime1")
        let p2Object = UserDefaults.standard.object(forKey: "prime2")
        let phiObject = UserDefaults.standard.object(forKey: "phi")
        let encryptionObject = UserDefaults.standard.object(forKey: "encryption")
        
        if let _ = highScoreObject as? Int, let n = nObject as? String, let e = eObject as? String, let p1 = p1Object as? String, let p2 = p2Object as? String, let phi = phiObject as? String, let encryption = encryptionObject as? String {

            messageComposeVC.body = "Hey! My encrypted high score in Prime Puppy is \(encryption). The two primes I used were \(p1) and \(p2). The exponent I chose was \(e) and the product and totient of those two numbers are \(n) and \(phi), respectively. Can you figure out what my score was?"
        }
        
        else {
            
            messageComposeVC.body = "Hey! My high score in Prime Puppy is a secret!"
            
        }
        
        return messageComposeVC
    }
    
    // MFMessageComposeViewControllerDelegate callback - dismisses the view controller when the user is finished with it
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
}
