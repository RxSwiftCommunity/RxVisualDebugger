//
//  RxSwiftDebugger.swift
//  Pods
//
//  Created by Krunoslav Zaher on 6/4/16.
//  Copyright (c) 2016 RxSwift Community
//

import Foundation
import RxSwift
import Swifter
import UIKit

extension ObservableType {
    public func debugRemote(id: String) -> Observable<Self.E> {
        return map { (element: Self.E) in
            let type = "\(Self.E.self)" == "()" ? "Void" : "\(Self.E.self)"
            logger.log(type, id: id, value: String(element))
            return element
        }
    }
}

public func initialize() {
    _ = logger // this starts server
}

func rootDir() -> String {
    let root = #file
    return (root as NSString).stringByDeletingLastPathComponent
}

func relativePath(path: String) -> String {
    let root = #file
    return (rootDir() as NSString).stringByAppendingPathComponent(path)
}

class Logger {

    var dataTask: NSURLSessionDataTask?
    let defaultSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())

    let initialTime = NSDate()
    var values = [(time: NSTimeInterval, type: String, id: String, value: String)]()

    let server: HttpServer

    init() {
        // attempt to run normal process from simulator, kind of failed
        //posix_spawn(nil, "/Applications/XXX.app/Contents/MacOS/".cStringUsingEncoding(NSUTF8StringEncoding), nil, nil, nil, nil)
        server = HttpServer()
        server["/log"] = { request in
            self.calculateLocked {
                defer { self.values = [] }
                return .OK(.Json(self.values.map {
                    [
                        "time" : $0.time,
                        "type" : $0.type,
                        "id" : $0.id,
                        "value" : $0.value
                    ]
                }))
            }
        }
        server["/setResolution"] = { request in
            dispatch_async(dispatch_get_main_queue()) {
                let device = { (deviceString: String) -> TargetDeviceScreen in
                    switch deviceString {
                    case "iPhone4":
                       return .Phone4
                    case "iPhone5":
                        return .Phone5
                    case "iPhone6":
                        return .Phone6
                    case "iPhone6Plus":
                        return .Phone6Plus
                    default:
                        return .Phone4
                    }
                }(request.queryParams.filter { $0.0 == "device" }.first?.1 ?? "")
                UIApplication.setScreenSize(device)
            }
            return .OK(.Text(""))
        }
        server["index.html"] = { request in
            return .OK(.Html((try? String(contentsOfFile: relativePath("index.html"), encoding: NSUTF8StringEncoding)) ?? ""))
        }
        server["/"] = { request in
            return .OK(.Html((try? String(contentsOfFile: relativePath("index.html"), encoding: NSUTF8StringEncoding)) ?? ""))
        }
        server["/files/:path"] = shareFilesFromDirectory(rootDir().stringByAppendingString("/files"))
        try! server.start(9911)
    }
    
    func log(type: String, id: String, value: String) {
        calculateLocked {
            let newLoggingElement = (
                time: -self.initialTime.timeIntervalSinceNow,
                type: type,
                id: id,
                value: value
                )
            self.values.append(newLoggingElement)
            print("log \(newLoggingElement)")
        }
    }
}

public enum TargetDeviceScreen {
    case Phone4
    case Phone5
    case Phone6
    case Phone6Plus
}

extension UIApplication {
    static func setScreenSize(device: TargetDeviceScreen) {
        let targetSize = device.resolution
        for window in sharedApplication().windows {
            var frame = window.frame
            frame.size = targetSize
            window.frame = frame
        }
    }
}

extension TargetDeviceScreen {
    var resolution: CGSize {
        switch self {
        case .Phone4:
            return CGSizeMake(320, 480)
        case .Phone5:
            return CGSizeMake(320, 568)
        case .Phone6:
            return CGSizeMake(375, 667)
        case .Phone6Plus:
            return CGSizeMake(414, 736)
        }
    }
}

extension Logger {
    private func calculateLocked<T>(action: () -> T) -> T {
        objc_sync_enter(self); defer { objc_sync_exit(self) }

        return action()
    }
}

let logger = Logger()