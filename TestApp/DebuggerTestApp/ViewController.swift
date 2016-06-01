//
//  ViewController.swift
//  DebuggerTestApp
//
//  Created by Marin Todorov on 5/31/16.
//  Copyright © 2016 Underplot ltd. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

class ViewController: UIViewController {

    @IBOutlet weak var btnTap: UIButton!
    @IBOutlet weak var btnDoh: UIButton!
    
    var bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //btnTap
        btnTap.rx_tap
            .scan(0, accumulator: { acc, _ in
                return acc+1
            })
            .map {num in "tap: \(num)"}
            .debugRemote("Tap Button")
            .subscribeNext {str in
                self.btnTap.setTitle(String(str), forState: .Normal)
            }
            .addDisposableTo(bag)
        
        //btnDoh
        btnDoh.rx_tap
            .debugRemote("Doh Button")
            .subscribeNext {_ in
                print("doh!")
            }
            .addDisposableTo(bag)
    }
}

