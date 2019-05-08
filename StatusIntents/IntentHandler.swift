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
        
        print("Handling some intent")
        return PrintStatusIntentHandler()
    }
    
}

class PrintStatusIntentHandler: NSObject, PrintStatusIntentHandling {
    func handle(intent: PrintStatusIntent, completion: @escaping (PrintStatusIntentResponse) -> Void) {
        print("Fetching printing status")
        API.instance.status { (status, filename, percentage, timeRemaining) in
            if (status == .Ok) {
                if (percentage == 100) {
                        completion(PrintStatusIntentResponse.success(filename: filename))
                } else {
                    let dcf = DateComponentsFormatter()
                    dcf.unitsStyle = .full
                    dcf.allowedUnits = [.hour, .minute]
                    dcf.zeroFormattingBehavior = [.pad]
                    completion(PrintStatusIntentResponse.stillPrinting(filename: filename, completion: percentage, finishTime: dcf.string(from: Double(timeRemaining))!))
                }
            } else {
                completion(PrintStatusIntentResponse.failure(errortext: "HTTP Error?"))
            }
        }
    }
}
