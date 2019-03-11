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
    func notify(message: String)
}

typealias Topic = NSNotification.Name

final class Push: WebSocketDelegate {
    // topics
    static let connected: Topic = NSNotification.Name("connected")
    static let current: Topic = NSNotification.Name("current")
    static let history: Topic = NSNotification.Name("history")
    static let event: Topic = NSNotification.Name("event")
    static let slicingProgress: Topic = NSNotification.Name("slicingProgress")
    static let plugin: Topic = NSNotification.Name("plugin")
    
    var socket: WebSocket!
    
    func connect() {
        socket = WebSocket(url: URL(string: "")!)
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
        // TODO: send auth message
        let json = ["auth": "API.instance.session_key"]
        socket.write(string: "some json")
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        print("Got data frame")
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        print("Got text frame")
        let json = JSON(text)
        switch json["type"] {
        case "connected": break
        case "current": break
        case "history": break
        case "event": break
        case "slicingProgress": break
        case "plugin": break
        default: break
        }
    }
}
