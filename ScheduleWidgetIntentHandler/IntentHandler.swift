//
//  IntentHandler.swift
//  ScheduleWidgetIntentHandler
//
//  Created by Anton Siliuk on 9/19/20.
//  Copyright © 2020 Saute. All rights reserved.
//

import Intents

class IntentHandler: INExtension, ConfigurationIntentHandling {

    func resolveGroup_number(for intent: ConfigurationIntent, with completion: @escaping (ScheduleIdentifierResolutionResult) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            completion(.disambiguation(with: [
                ScheduleIdentifier(identifier: "1234", display: "014567"),
                ScheduleIdentifier(identifier: "1235", display: "014568"),
                ScheduleIdentifier(identifier: "1236", display: "014569"),
                ScheduleIdentifier(identifier: "1237", display: "014560"),
            ]))
        }
    }

    func resolveLecturer(for intent: ConfigurationIntent, with completion: @escaping (ScheduleIdentifierResolutionResult) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            completion(.disambiguation(with: [
                ScheduleIdentifier(identifier: "1234", display: "Иванов И.В."),
                ScheduleIdentifier(identifier: "1235", display: "Петров И.В."),
                ScheduleIdentifier(identifier: "1236", display: "Иванова И.В."),
                ScheduleIdentifier(identifier: "1237", display: "Сидоров И.В."),
            ]))
        }
    }

    override func handler(for intent: INIntent) -> Any {
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.
        
        return self
    }
    
}
