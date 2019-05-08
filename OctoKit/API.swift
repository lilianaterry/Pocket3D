//
//  API.swift
//  Pocket3D
//
//  Created by Chris Day on 2/26/19.
//  Copyright © 2019 Team 2. All rights reserved.
//

import Alamofire
import SwiftyJSON

public final class API {
    public enum ResponseType { case String, JSON }

    public enum Status {
        case Ok, Fail

        static func && (lhs: Status, rhs: Status) -> Status {
            return lhs == .Ok && rhs == .Ok ? .Ok : .Fail
        }
    }

    public typealias JsonCallback = (Status, JSON) -> Void
    public typealias Callback = (Status) -> Void

    public static let instance = API()

    private var orig_url: URL!
    private var url: URL!
    private var api_key: String!

    private var headers: [String: String] {
        return ["X-Api-Key": self.api_key]
    }
    
    init() {
        let ud = UserDefaults.init(suiteName: "group.utexas.cs371.team2.Pocket3D")!
        if let ip = ud.string(forKey: "ipAddress"),
            let api = ud.string(forKey: "apiKey") {
            // we can initialize without setup being called
            self.orig_url = URL(string: ip)!
            self.url = self.orig_url.appendingPathComponent("api")
            self.api_key = api;
        }
    }

    public func setup(url: String, key: String) {
        orig_url = URL(string: url)
        api_key = key
        self.url = orig_url.appendingPathComponent("api")
    }

    public func login(callback: @escaping JsonCallback) {
        performPost(path: "login", parameters: ["passive": true]).responseJSON { res in
            let json = JSON(res.data as Any)
            NSLog("Got session key \(json["session"])")
            if res.response?.statusCode == 200 {
                callback(.Ok, json)
                print("Login apparently successful I guess?")
            } else {
                print("Login Failure")
                callback(.Fail, json)
            }
        }
    }

    public func stream() -> URL? {
        var qurl = URLComponents(url: orig_url, resolvingAgainstBaseURL: true)!
        var qi = qurl.queryItems ?? []
        // TODO: this is the default, add to settings at some point
        qi.append(URLQueryItem(name: "action", value: "stream"))
        qurl.queryItems = qi
        qurl.path = "/webcam/"
        return qurl.url
    }

    public func move(x: Float? = .none, y: Float? = .none, z: Float? = .none, f: Float? = .none, callback: @escaping Callback) {
        var params: [String: Any] = ["command": "jog", "absolute": true]
        if let x = x {
            params["x"] = x
        }
        if let y = y {
            params["y"] = y
        }
        if let z = z {
            params["z"] = z
        }
        if let f = f {
            params["speed"] = f
        }
        performPostDefault(paths: ["printer", "printhead"], parameters: params, callback: callback)
    }

    public func home(axes: [String], callback: @escaping Callback) {
        performPostDefault(paths: ["printer", "printhead"], parameters: ["axes": axes], callback: callback)
    }

    public func extruderHeat(hotness: Float, callback: @escaping Callback) {
        performPostDefault(paths: ["printer", "tool"],
                           parameters: ["command": "target", "targets": ["tool0": hotness]],
                           callback: callback)
    }

    public func bedHeat(hotness: Float, callback: @escaping Callback) {
        performPostDefault(paths: ["printer", "bed"],
                           parameters: ["command": "target", "target": hotness],
                           callback: callback)
    }
    
    // this function is different because intent compilation
    // breaks swiftjson which is sick
    public func status(callback: @escaping (Status, String, NSNumber, NSNumber) -> Void) {
        Alamofire.request(url.appendingPathComponent("job"), headers: headers).responseJSON { (data) in
            let js = JSON(data.data!)
            callback(data.response?.statusCode == 200 ? .Ok : .Fail, js["job"]["file"]["name"].stringValue, js["progress"]["completion"].numberValue, js["progress"]["printTimeLeft"].numberValue)
        }
    }

    public func pause(callback: @escaping Callback) {
        performPostDefault(paths: ["job"],
                           parameters: ["command": "pause", "action": "toggle"],
                           callback: callback)
    }

    public func cancel(callback: @escaping Callback) {
        performPostDefault(paths: ["job"], parameters: ["command": "cancel"], callback: callback)
    }

    public func files(callback: @escaping JsonCallback) {
        Alamofire.request(url.appendingPathComponent("files"),
                          headers: headers).responseJSON { data in
            callback(data.response?.statusCode == 200 ? .Ok : .Fail,
                     JSON(data.data!))
        }
    }

    public func printFile(file: URL, callback: @escaping Callback) {
        performPostDefault(paths: Array(file.pathComponents[2...]),
                           parameters: ["command": "select", "print": true],
                           callback: callback)
    }

    public func commands(commands: [String], callback: @escaping Callback) {
        performPostDefault(paths: ["printer", "command"],
                           parameters: ["commands": commands],
                           callback: callback)
    }

    private func performPost(path: String, parameters: [String: Any] = [:]) -> DataRequest {
        return performPost(paths: [path], parameters: parameters)
    }

    private func performPost(paths: [String], parameters: [String: Any] = [:]) -> DataRequest {
        return Alamofire.request(buildMultipath(paths), method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
    }

    private func performPostDefault(paths: [String],
                                    parameters: [String: Any] = [:],
                                    callback: @escaping Callback) {
        performPost(paths: paths, parameters: parameters).response(completionHandler: { ddr in
            if ddr.response?.statusCode == 204 {
                callback(.Ok)
            } else {
                print("Request against \(String(describing: ddr.request?.url)) failed: \(String(describing: ddr.response?.statusCode))")
                callback(.Fail)
            }
        })
    }

    private func buildMultipath(_ paths: [String]) -> URL {
        return paths.reduce(url) { acc, x in acc!.appendingPathComponent(x) }!
    }
}
