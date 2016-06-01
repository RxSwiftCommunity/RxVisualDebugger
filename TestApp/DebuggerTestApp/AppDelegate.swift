//
//  AppDelegate.swift
//  DebuggerTestApp
//
//  Created by Marin Todorov on 5/31/16.
//  Copyright © 2016 Underplot ltd. All rights reserved.
//

import UIKit
import RxSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let bag = DisposeBag()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        return true
    }
}

extension ObservableType {
    func debugRemote(id: String) -> Observable<Self.E> {
        return map({ (element: Self.E) in
            let type = "\(Self.E.self)" == "()" ? "Void" : "\(Self.E.self)"
            logger.log("[\(type)] \(id)", value: String(element))
            return element
        })
    }
}

class Logger {
    var dataTask: NSURLSessionDataTask?
    let defaultSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
    
    func log(index: String, value: String) {
        
        if dataTask != nil {
            dataTask?.cancel()
        }
        
        let expectedCharSet = NSCharacterSet.URLQueryAllowedCharacterSet()
        let log = value.stringByAddingPercentEncodingWithAllowedCharacters(expectedCharSet)!
        let name = index.stringByAddingPercentEncodingWithAllowedCharacters(expectedCharSet)!
        
        let url = NSURL(string: "http://localhost:9911/log?index=\(name)&value=\(log)")
        print("log: index=\(name) value=\(value)")
        // 5
        
        dataTask = defaultSession.dataTaskWithURL(url!) {
            data, response, error in
            
            if let error = error {
                print(error.localizedDescription)
            } else if let httpResponse = response as? NSHTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    //print("logged")
                }
            }
        }
        // 8
        dataTask?.resume()
    }
}

let logger = Logger()
