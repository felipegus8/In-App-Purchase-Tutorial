//
//  ViewController.swift
//  In App Purchase Tutorial
//
//  Created by Felipe Viberti on 18/07/17.
//  Copyright © 2017 Felipe Viberti. All rights reserved.
//

import UIKit
import StoreKit

class ViewController: UIViewController {

    @IBOutlet weak var valorMoedas: UILabel!
    var request: SKProductsRequest!
    var list = [SKProduct]()
    var p = SKProduct()
    var qtdMoedas = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        permitirPagamentos()
        valorMoedas.text = String(qtdMoedas)
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func fazerCompra10Moedas(_ sender: UIButton) {
        for product in list {
            if product.productIdentifier == "Pack_de_10_moedas"{
              p = product
              comprarProduto()
            }
        }
    }

    func comprarProduto() {
        print("comprar" + p.productIdentifier)
        let pay = SKPayment(product: p)
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().add(pay as SKPayment)
    }
    
    func permitirPagamentos() {
        if(SKPaymentQueue.canMakePayments()) {
            print("IAP estão disponíveis, carregando")
            let productID:NSSet = NSSet(objects: "Pack_de_10_moedas")
            print(productID)
            request = SKProductsRequest(productIdentifiers: productID  as! Set<String>)
            request.delegate = self
            request.start()
        } else {
            print("IAP  não estão disponíveis")
        }
    }
    
    func adicionarMoedas () {
        print("Entrou aqui")
        qtdMoedas += 10
        valorMoedas.text = String(qtdMoedas)
    }
    
}


extension ViewController:SKProductsRequestDelegate {
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print("Request foi feito")
        let myProduct = response.products
        
        for product in myProduct {
            print("Produto Adicionado")
            print(product.productIdentifier)
            print(product.localizedTitle)
            print(product.localizedDescription)
            print(product.price)
            list.append(product)
        }
    }
}


extension ViewController:SKPaymentTransactionObserver {
    
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        print("Received payment transaction response from Apple")
        
        for transaction:AnyObject in transactions {
            let trans = transaction as! SKPaymentTransaction
            switch trans.transactionState {
                
            case .purchased, .restored:
                print(p.productIdentifier)
                
                let prodID = p.productIdentifier as String
                switch prodID {
                case "Pack_de_10_moedas":
                 print("Bought 10 coins")
                 adicionarMoedas()
                default:
                    print("IAP not setup")
                }
                queue.finishTransaction(trans)
                break;
            case .failed:
                print("buy error")
                queue.finishTransaction(trans)
                break;
            default:
                print("default")
                break;
                
            }
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error){
        print(error)
    }
}
