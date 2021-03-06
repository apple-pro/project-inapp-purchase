//
//  QuoteTableViewController.swift
//  InspoQuotes
//
//  Created by Angela Yu on 18/08/2018.
//  Copyright © 2018 London App Brewery. All rights reserved.
//

import UIKit
import StoreKit

class QuoteTableViewController: UITableViewController, SKPaymentTransactionObserver {
    
    @IBOutlet weak var restoreButton: UIBarButtonItem!
    
    let freeQoutes = [
        "Our greatest glory is not in never falling, but in rising every time we fall. — Confucius",
        "All our dreams can come true, if we have the courage to pursue them. – Walt Disney",
        "It does not matter how slowly you go as long as you do not stop. – Confucius",
        "Everything you’ve ever wanted is on the other side of fear. — George Addair",
        "Success is not final, failure is not fatal: it is the courage to continue that counts. – Winston Churchill",
        "Hardships often prepare ordinary people for an extraordinary destiny. – C.S. Lewis"
    ]
    
    let premiumQuotes = [
        "Believe in yourself. You are braver than you think, more talented than you know, and capable of more than you imagine. ― Roy T. Bennett",
        "I learned that courage was not the absence of fear, but the triumph over it. The brave man is not he who does not feel afraid, but he who conquers that fear. – Nelson Mandela",
        "There is only one thing that makes a dream impossible to achieve: the fear of failure. ― Paulo Coelho",
        "It’s not whether you get knocked down. It’s whether you get up. – Vince Lombardi",
        "Your true success in life begins only when you make the commitment to become excellent at what you do. — Brian Tracy",
        "Believe in yourself, take on your challenges, dig deep within yourself to conquer fears. Never let anyone bring you down. You got to keep going. – Chantal Sutherland"
    ]

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        SKPaymentQueue.default().add(self)
    }
    
    // MARK: - TableView DataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if hasPremiumQoutes() {
            return qoutesToShow().count
        }
        
        return qoutesToShow().count + 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuoteCell", for: indexPath)
        cell.textLabel?.numberOfLines = 0
        
        if indexPath.row < qoutesToShow().count {
            cell.textLabel?.text = qoutesToShow()[indexPath.row]
            cell.textLabel?.textColor = UIColor(named: "label")
            cell.accessoryType = .none
        } else {
            cell.textLabel?.text = "Get More Qoutes"
            cell.textLabel?.textColor = UIColor(named: "themeBG")
            cell.accessoryType = .disclosureIndicator
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row >= qoutesToShow().count {
            print("Selected Pay")
            buyPremiumQoutes()
        } else {
            print("Selected Qoute")
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Payment Processing
    
    func buyPremiumQoutes() {
        if SKPaymentQueue.canMakePayments() {
            let paymentRequest = SKMutablePayment()
            paymentRequest.productIdentifier = "info.starupbuilder.InspoQoute.PremiumQoutes" //set this up in apple connect
            SKPaymentQueue.default().add(paymentRequest)
        } else {
            print("Cant make a payment")
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
        for txn in transactions {
            if txn.transactionState == .purchased {
                addPremium()
            } else if txn.transactionState == .purchased || txn.transactionState == .restored {
                //also check if the transaction is of the right product id
                //https://developer.apple.com/documentation/storekit/in-app_purchase/unlocking_purchased_content
                addPremium()
                SKPaymentQueue.default().finishTransaction(txn)
            } else {
                let alert = UIAlertController(title: "Error", message: "Payment Processing Failed", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true)
            }
        }
    }
    
    @IBAction func restorePressed(_ sender: UIBarButtonItem) {
        //fake: just to simulate a successful payment
        if hasPremiumQoutes() {
            removePremium()
        } else {
            //this will retrigger the paymentQueue(updatedTransactions) method
            //as if your are done making the purchase
            //so no code duplication. Hooray!!!
            SKPaymentQueue.default().restoreCompletedTransactions()
        }
    }

    // MARK: - Support
    
    func qoutesToShow() -> [String] {
        
        if hasPremiumQoutes() {
            return freeQoutes + premiumQuotes
        }
        
        return freeQoutes
    }
    
    func hasPremiumQoutes() -> Bool {
        UserDefaults.standard.bool(forKey: K.Premium)
    }
    
    func removePremium() {
        UserDefaults.standard.set(false, forKey: K.Premium)
        tableView.reloadData()
    }
    
    func addPremium() {
        UserDefaults.standard.set(true, forKey: K.Premium)
        tableView.reloadData()
        navigationItem.setRightBarButton(nil, animated: true)
    }
    
    
}
