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
        
        static func &&(lhs: Status, rhs: Status) -> Status {
            return lhs == .Ok && rhs == .Ok ? .Ok : .Fail
        }
    }
    
    typealias JsonCallback = (JSON) -> Void
    typealias Callback = (Status) -> Void
    
    static let instance = API()
    
    var orig_url: URL!
    var url: URL!
    var api_key: String!
    
    var headers: [String: String] {
        return ["X-Api-Key": self.api_key]
    }
    
    func setup(url: String, key: String) {
        self.orig_url = URL(string: url)
        self.url = URL(string: url)!.appendingPathComponent("api")
        self.api_key = key
    }
    
    func stream() -> URL? {
        var qurl = URLComponents(url: self.orig_url, resolvingAgainstBaseURL: true)!
        var qi = qurl.queryItems ?? []
        // TODO: this is the default, add to settings at some point
        qi.append(URLQueryItem(name: "action", value: "stream"))
        qurl.queryItems = qi
        return qurl.url
    }
    
    func move(x: Int? = .none, y: Int? = .none, z: Int? = .none, f: Int? = .none, callback: @escaping Callback) {
        var params: [String: Any] = [:]
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
        self.performPostDefault(paths: ["printer", "printhead"], parameters: params, callback: callback)
    }
    
    func home(axes: [String], callback: @escaping Callback) {
        self.performPostDefault(paths: ["printer", "printhead"], parameters: ["axes": axes], callback: callback)
    }
    
    /*
     * If both heat arguments are given, two web requests are performed and
     * their results are and-ed
     *
     * WEW LADDIE THIS IS INTERESTING
     */
    func heat(hotend: Int? = .none, bed: Int? = .none, callback: @escaping Callback) {
        let d = DispatchQueue(label: "heaterqueue")
        var hres: Status? = .none
        var bres: Status? = .none
        if let h = hotend {
            Alamofire.request(self.buildMultipath(["printer", "tool"]),
                              parameters: ["command": "target", "targets": ["tool0": h]],
                              encoding: JSONEncoding.default,
                              headers: self.headers).response(queue: d) { response in
                // yeet
                hres = response.response?.statusCode == 204 ? .Ok : .Fail
            }
        }
        if let b = bed {
            Alamofire.request(self.buildMultipath(["printer", "bed"]),
                              parameters: ["command": "target", "target": b],
                              encoding: JSONEncoding.default,
                              headers: self.headers).response(queue: d) { response in
                // yeet
                bres = response.response?.statusCode == 204 ? .Ok : .Fail
            }
        }
        d.async {
            // So the theory is since d is a synchronous dispatch queue, then
            // this will be queued last and both hres and bres will be updated correctly.
            // However this is turbo ultra memory unsafe and might not work.
            // If it does, Dijkstra bless reference counting and closure capture semantics.
            callback(hres ?? .Ok && bres ?? .Ok)
        }
    }
    
    func files(callback: @escaping JsonCallback) {
        Alamofire.request(self.url.appendingPathComponent("files"),
                          headers: self.headers).responseJSON { data in
            callback(JSON(data))
        }
    }
    
    func printFile(file: URL, callback: @escaping Callback) {
        self.performPostDefault(paths: Array(file.pathComponents[1...]),
                                parameters: ["command": "select", "print": true],
                                callback: callback)
    }
    
    func commands(commands: [String], callback: @escaping Callback) {
        self.performPostDefault(paths: ["printer", "command"],
                                parameters: ["commands": commands],
                                callback: callback)
    }
    
    func performPost(path: String, parameters: [String: Any] = [:]) -> DataRequest {
        return self.performPost(paths: [path], parameters: parameters)
    }
    
    func performPost(paths: [String], parameters: [String: Any] = [:]) -> DataRequest {
        return Alamofire.request(self.buildMultipath(paths), parameters: parameters, encoding: JSONEncoding.default, headers: self.headers)
    }
    
    func performPostDefault(paths: [String],
                            parameters: [String: Any] = [:],
                            callback: @escaping Callback) {
        self.performPost(paths: paths, parameters: parameters).response(completionHandler: { ddr in
            callback(ddr.response?.statusCode == 204 ? .Ok : .Fail)
        })
    }
    
    func buildMultipath(_ paths: [String]) -> URL {
        return paths.reduce(self.url, { acc, x in acc!.appendingPathComponent(x) })!
    }
}
