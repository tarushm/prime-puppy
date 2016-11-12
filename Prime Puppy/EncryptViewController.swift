//
//  EncryptViewController.swift
//  Prime Puppy
//
//  Created by Tarush Mohanti on 11/12/16.
//  Copyright © 2016 tarush. All rights reserved.
//

import UIKit

// Access the existing sieve function and reuse it

// This is an RSA Encryption, so the user can encrypt their incredibly private scores

let game = GameScene()

// Generate two large primes, close together, within a 1000

let largePrimes = twoPrimes(arr: game.sieve(count: Int(arc4random_uniform(1000))))

let n = largePrimes[0] * largePrimes[1]

let e = coprime(n: phi(arr: largePrimes))

class EncryptViewController: UIViewController, UITextFieldDelegate{

    @IBOutlet var inputText: UITextField!
    @IBOutlet var prime1: UILabel!
    @IBOutlet var prime2: UILabel!
    @IBOutlet var nLabel: UILabel!
    @IBOutlet var phiLabel: UILabel!
    @IBOutlet var eLabel: UILabel!

    @IBAction func encryptButton(_ sender: Any) {
        
        if let text = inputText.text, !text.isEmpty
        {
            if (Int(text) != nil) {
                resultText.text = String(encrypt(message: Int(inputText.text!)!, e: e, n: n))
                UserDefaults.standard.set(resultText.text, forKey: "encryption")
            }
            else {
                resultText.text = ("You need to enter an integer")
            }
        }
        else {
            resultText.text = ("You have to enter a score!")
        }
        
    }
        
    
    @IBOutlet var resultText: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(largePrimes)
        print(phi(arr: largePrimes))
        
        let highScoreObject = UserDefaults.standard.object(forKey: "highScore")
        
        if let highScore = highScoreObject as? Int {
            
            inputText.text = String(highScore)
        
        }
        
        // The product of the two primes
        
        nLabel.text = String(largePrimes[0]*largePrimes[1])
        UserDefaults.standard.set(nLabel.text, forKey: "n")
        
        // The 'e' or exponent
        
        eLabel.text = String(e)
        UserDefaults.standard.set(eLabel.text, forKey: "e")
        
        // The first of the primes
        
        prime1.text = String(largePrimes[0])
        UserDefaults.standard.set(prime1.text, forKey: "prime1")
        
        // The second of the primes
        
        prime2.text = String(largePrimes[1])
        UserDefaults.standard.set(prime2.text, forKey: "prime2")
        
        // The totient, or phi function of the product
        
        phiLabel.text = String(phi(arr: largePrimes))
        UserDefaults.standard.set(phiLabel.text, forKey: "phi")
        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.view.endEditing(true)
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    // Create a MessageComposer
    
    // https://developer.apple.com/reference/messageui/mfmessagecomposeviewcontroller
    let messageComposer = MessageComposer()
    
    @IBAction func sendTextMessageButtonTapped(_ sender: Any) {
        
        // Make sure the device can send text messages
        if (messageComposer.canSendText()) {
            let messageComposeVC = messageComposer.configuredMessageComposeViewController()
            
            present(messageComposeVC, animated: true, completion: nil)
        } else {
            print("User cannot access text messages")
        }

    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

/*

func sieve (count:Int) -> [Bool] {
    
    assert(count > 0, "Value must be a positive integer")
    
    var A = [Bool!](repeating: true, count: count)
    
    var i = 2
    while (i <= Int(sqrt(Double(count)))){
        
        if A[i]! {
            
            var j = (i*i)
            while (j < count){
                
                A[j] = false
                j += i
                
            }
            
        }
        
        i += 1
        
    }
    
    return(A)
    
}
 
 */

// Easily find two primes close to each other

func twoPrimes(arr: [Bool]) -> [Int] {
    
    var B = [Int]()
    for (index,element) in arr.enumerated(){
        if element && index > Int(arr.count/2) {
            B.append(index)
        }
    }
    
    return([B[0],B[1]])
}

// The phi function to find the totient given, with two possible parameter varities

func phi(arr: [Int]) -> Int {
    assert(arr.count == 2)
    return (arr[0]-1)*(arr[1]-1)
}

func phi(a: Int, b: Int) -> Int {
    return (a-1)*(b-1)
}

// What we use to encrypt the message, given the message, e the exponent co prime, and n the product

func encrypt(message: Int, e: Int, n: Int) -> Int {
    
    return Int(pow(Double(message),Double(e)))%n
    
}

// Function to find 'e' the smallest coprime

func coprime(n: Int) -> Int {
    
    var i = 1
    while (i < n) {
        if (n % i != 0) {
            return i
        }
        i += 1
    }
    return 0
    
}

// Not working, which is why we are texting it to a trusted friend

func privateKeyGen(a: Int, b: Int) -> Int {
    var p = a
    var q = b
    
    var x = [0,1,0]
    var y = [0,1,0]
    
    var quotient = p/q
    var remainder = p%q
    
    x[0] = 0
    y[0] = 1
    x[1] = 1
    y[1] = quotient * -1
    
    var i = 2
    
    while (q%(p%q) != 0 && x[(i-1)%3] > 0) {
        p = q
        q = remainder
        quotient = p/q
        remainder = p%q
        x[i % 3] = (quotient * -1 * x[(i - 1) % 3]) + x[(i - 2) % 3]
        y[i % 3] = (quotient * -1 * y[(i - 1) % 3]) + y[(i - 2) % 3]
        i += 1
    }
    
    return x[(i-1)%3]
    
}
