//
//  Push.swift
//  Pocket3D
//
//  Created by Chris Day on 3/6/19.
//  Copyright © 2019 Team 2. All rights reserved.
//

import Foundation
import Starscream
import SwiftyJSON
// https://docs.octoprint.org/en/master/api/push.html#current-and-history-payload
// implement a observable endpoint for each of these messages
// TODO: manage subscription data and websocket stuff
// TODO: the UI will use the observer pattern for all of this
// TODO: but it should only be temperature watching at the moment
// TODO: as well as job progress
// TODO: make sure to set the throttle argument

@objc protocol Observer {
    func notify(message: Notification)
}

typealias Topic = NSNotification.Name

final class Push: WebSocketDelegate {
    // Singleton
    static let instance = Push()
    
    // topics
    static let connected: Topic = NSNotification.Name("connected")
    static let current: Topic = NSNotification.Name("current")
    static let history: Topic = NSNotification.Name("history")
    static let event: Topic = NSNotification.Name("event")
    static let slicingProgress: Topic = NSNotification.Name("slicingProgress")
    static let plugin: Topic = NSNotification.Name("plugin")
    
    var socket: WebSocket!
    var sessionKey: String = ""
    var name: String = ""
    
    func connect(baseUrl: URL, name: String, sessionKey: String) {
        var components = URLComponents(url: baseUrl, resolvingAgainstBaseURL: true)!
        components.scheme = "ws"
        components.path = "/sockjs/\(name)/\(sessionKey)/websocket"
        print("Connecting to \(String(describing: components.url))")
        socket = WebSocket(url: components.url!)
        self.sessionKey = sessionKey
        self.name = name
        socket.delegate = self
        socket.connect()
    }
    
    func disconnect() {
        socket.disconnect()
    }
    
    func observe(who: Observer, topic: Topic) {
        NotificationCenter.default.addObserver(who,
                                               selector: #selector(Observer.notify(message:)),
                                               name: topic,
                                               object: nil)
    }
    
    func websocketDidConnect(socket: WebSocketClient) {
        // We only get heartbeat packets until correctly authenticated
        
        // Yes, this stupid json object is the correct format. For whatever reason,
        // all outgoing values must be arrays of json formatted strings
        let json = JSON([JSON(["auth": self.name + ":" + self.sessionKey]).rawString()!])
        let authstr = json.rawString(options: [])!
        print("Sending auth packet \(authstr)")
        socket.write(string: authstr)
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print("Websocket error \(String(describing: error))")
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        print("Got data frame \(String(describing: String(data: data, encoding: .utf8)))")
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        // From experimentation, everything is a text frame
        // Also wow ok nothing matches the documentation
        // h: a heartbeat packet
        // o: Not sure, maybe connection?
        // a: a json object follows
        
        switch text.first {
        case "o":
            // no clue
            break
        case "a":
            // ew
            let json = try! JSON(data:
                String(text.dropFirst()).data(using: .utf8,
                                              allowLossyConversion: false)!).arrayValue
            for elem in json {
                for (key, value) in elem {
                    //print("Parsing \(key) message")
                    switch key {
                    case "connected":
                        // there isn't much we need from a connected response
                        break
                    case "current":
                        NotificationCenter.default.post(name: Push.current, object: value)
                    case "history": break
                    case "event": break
                    case "slicingProgress": break
                    case "plugin": break
                    default: break
                    }
                }
            }
        case "h":
            // heartbeat
            print("💓")
        default:
            print("Unknown message start \(String(describing: text.first))")
        }
    }
}
