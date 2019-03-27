//
//  API.swift
//  Pocket3D
//
//  Created by Chris Day on 2/26/19.
//  Copyright © 2019 Team 2. All rights reserved.
//

import Alamofire
import SwiftyJSON

final class API {
    enum ResponseType { case String, JSON }

    enum Status {
        case Ok, Fail

        static func && (lhs: Status, rhs: Status) -> Status {
            return lhs == .Ok && rhs == .Ok ? .Ok : .Fail
        }
    }

    typealias JsonCallback = (Status, JSON) -> Void
    typealias Callback = (Status) -> Void

    static let instance = API()

    private var orig_url: URL!
    private var url: URL!
    private var api_key: String!

    private var debug_enabled: Bool = true

    private var headers: [String: String] {
        return ["X-Api-Key": self.api_key]
    }

    func setup(url: String, key: String) {
        // Chris's hardcoded shieeeeet
        // Use debug stuff if the debug thing above is enabled
        // and DEBUG is entered in a field
        if url == "DEBUG" || key == "DEBUG", debug_enabled {
            orig_url = URL(string: "http://70.122.32.48")
            api_key = "B7714E03A6524843BBB26F946D59AE70"
            // Virtual printer shit maybe fuck it I don't know
            // self.orig_url = URL(string: "http://localhost:5000")
            // self.api_key = "589F0038062E48CBAB0191A0CF9CC7AC"
        } else {
            orig_url = URL(string: url)
            api_key = key
        }
        self.url = orig_url.appendingPathComponent("api")
    }

    func login(callback: @escaping JsonCallback) {
        performPost(path: "login", parameters: ["passive": true]).responseJSON { res in
            let json = JSON(res.data as Any)
            NSLog("Got session key \(json["session"])")
            if res.response?.statusCode == 200 {
                Push.instance.connect(baseUrl: self.orig_url,
                                      name: json["name"].stringValue,
                                      sessionKey: json["session"].stringValue)
                callback(.Ok, json)
                print("Login apparently successful I guess?")
            } else {
                print("Login Failure")
                callback(.Fail, json)
            }
        }
    }

    func stream() -> URL? {
        var qurl = URLComponents(url: orig_url, resolvingAgainstBaseURL: true)!
        var qi = qurl.queryItems ?? []
        // TODO: this is the default, add to settings at some point
        qi.append(URLQueryItem(name: "action", value: "stream"))
        qurl.queryItems = qi
        qurl.path = "/webcam/"
        return qurl.url
    }

    func move(x: Float? = .none, y: Float? = .none, z: Float? = .none, f: Float? = .none, callback: @escaping Callback) {
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

    func home(axes: [String], callback: @escaping Callback) {
        performPostDefault(paths: ["printer", "printhead"], parameters: ["axes": axes], callback: callback)
    }

    func extruderHeat(hotness: Float, callback: @escaping Callback) {
        performPostDefault(paths: ["printer", "tool"],
                           parameters: ["command": "target", "targets": ["tool0": hotness]],
                           callback: callback)
    }

    func bedHeat(hotness: Float, callback: @escaping Callback) {
        performPostDefault(paths: ["printer", "bed"],
                           parameters: ["command": "target", "target": hotness],
                           callback: callback)
    }

    // TODO: M114 support
    // Recv: X:0.000 Y:0.000 Z:59.818 E:40.629

    func files(callback: @escaping JsonCallback) {
        Alamofire.request(url.appendingPathComponent("files"),
                          headers: headers).responseJSON { data in
            callback(data.response?.statusCode == 200 ? .Ok : .Fail,
                     JSON(data.data!))
        }
    }

    func printFile(file: URL, callback: @escaping Callback) {
        performPostDefault(paths: Array(file.pathComponents[2...]),
                           parameters: ["command": "select", "print": true],
                           callback: callback)
    }

    func commands(commands: [String], callback: @escaping Callback) {
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
