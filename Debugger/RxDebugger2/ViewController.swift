//
//  ViewController.swift
//  RxDebugger2
//
//  Created by Marin Todorov on 6/1/16.
//  Copyright © 2016 Underplot ltd. All rights reserved.
//

import Cocoa
import WebKit

import RxSwift
import RxCocoa
import Swifter

extension String {
    func indexOf(string: String) -> String.Index {
        return rangeOfString(string, options: .LiteralSearch, range: nil, locale: nil)?.startIndex ?? startIndex
    }
}

func delay(delay: Double, closure: ()->Void) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}

class ViewController: NSViewController {

    var timer: Observable<NSInteger>!
    var bag = DisposeBag()
    var server: HttpServer!
    
    @IBOutlet weak var webView: WebView!
    
    func matchesForRegexInText(regex: String!, text: String!) -> [String] {
        
        do {
            let regex = try NSRegularExpression(pattern: regex, options: [])
            let nsString = text as NSString
            let results = regex.matchesInString(text,
                                                options: [], range: NSMakeRange(0, nsString.length))
            return results.map { nsString.substringWithRange($0.range)}
        } catch let error as NSError {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadTimeline()
        startServer()
    }
    
    deinit {
        server.stop()
    }

    @IBAction func reload(sender: AnyObject) {
        loadTimeline()
    }
    
    func loadTimeline() {
        let url = NSBundle.mainBundle().URLForResource("timeline", withExtension: "html")!
        var html = try! NSString(contentsOfURL: url, encoding: NSUTF8StringEncoding) as String
        let replacements = matchesForRegexInText("url\\{\\{[^\\}]+\\}\\}", text: html)
        for match in replacements {
            var file = match.stringByReplacingOccurrencesOfString("url{{", withString: "")
            file = file.stringByReplacingOccurrencesOfString("}}", withString: "")
            file = NSBundle.mainBundle().URLForResource(file, withExtension: nil)!.absoluteString
            html = html.stringByReplacingOccurrencesOfString(match, withString: file)
        }
        
        //remove web
        let startWeb = html.indexOf("<!-- [if web] -->")
        let endMarker = "<!-- [endif] -->"
        let endWeb = html.indexOf(endMarker).advancedBy(endMarker.utf8.count)
        html = html.stringByReplacingCharactersInRange(startWeb...endWeb, withString: "")
        
        //remove IE6
        html = html.stringByReplacingOccurrencesOfString("<!--[if IE6]>", withString: "")
        html = html.stringByReplacingOccurrencesOfString("<![endif]-->", withString: "")
        
        webView.mainFrame.loadHTMLString(html, baseURL: NSBundle.mainBundle().URLForResource("timeline", withExtension: "html")!.baseURL)
    }
    
    func startServer() {
        server = HttpServer()
        server["/log"] = {request in
            if let logParam = request.queryParams.filter({pair in pair.0 == "value"}).first,
                let indexParam = request.queryParams.filter({pair in pair.0 == "index"}).first
            {
                self.log(indexParam.1, value: logParam.1)
            }
            
            return .OK(.Html("OK"))
        }
        try! server.start(9911)
    }
    
    func log(index: String, value: String) {
        let js = "logEvent(\"\(index)\", \"\(value)\")"
        self.webView.stringByEvaluatingJavaScriptFromString(js)
    }
    
    @IBAction func timelineFit(sender: AnyObject) {
        let js = "timelineFit()"
        self.webView.stringByEvaluatingJavaScriptFromString(js)
    }
    
    @IBAction func timelineFocus(sender: AnyObject) {
        let js = "timelineFocus()"
        self.webView.stringByEvaluatingJavaScriptFromString(js)
    }
    
}