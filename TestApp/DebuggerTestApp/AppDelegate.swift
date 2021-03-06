//
//  AppDelegate.swift
//  DebuggerTestApp
//
//  Created by Marin Todorov on 5/31/16.
//  Copyright © 2016 Underplot ltd. All rights reserved.
//

import UIKit
import RxSwift
import RxVisualDebugger

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let bag = DisposeBag()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        RxVisualDebugger.initialize()
        return true
    }
}

