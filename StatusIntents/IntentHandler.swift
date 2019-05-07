//
//  IntentHandler.swift
//  StatusIntents
//
//  Created by Chris Day on 4/29/19.
//  Copyright © 2019 Team 2. All rights reserved.
//

import Intents
import OctoKit
import SwiftyJSON

class IntentHandler: INExtension {
    
    override func handler(for intent: INIntent) -> Any {
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.
        
        return PrintStatusIntentHandler()
    }
    
}

class PrintStatusIntentHandler: NSObject, PrintStatusIntentHandling {
    func handle(intent: PrintStatusIntent, completion: @escaping (PrintStatusIntentResponse) -> Void) {
        API.instance.status { (status, filename, percentage, timeRemaining) in
            if (status == .Ok) {
                completion(PrintStatusIntentResponse.success(filename: filename, completion: percentage))
            } else {
                completion(PrintStatusIntentResponse.failure(errortext: "HTTP Error?"))
            }
        }
    }
}
