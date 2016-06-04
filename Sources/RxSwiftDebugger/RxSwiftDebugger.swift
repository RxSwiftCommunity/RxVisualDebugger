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
        server["index.html"] = { request in
            return .OK(.Html((try? String(contentsOfFile: relativePath("index.html"), encoding: NSUTF8StringEncoding)) ?? ""))
        }
        server["/"] = { request in
            return .OK(.Html((try? String(contentsOfFile: relativePath("index.html"), encoding: NSUTF8StringEncoding)) ?? ""))
        }
        server["/files/:path"] = HttpHandlers.shareFilesFromDirectory(rootDir())
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

extension Logger {
    private func calculateLocked<T>(action: () -> T) -> T {
        objc_sync_enter(self); defer { objc_sync_exit(self) }

        return action()
    }
}

let logger = Logger()