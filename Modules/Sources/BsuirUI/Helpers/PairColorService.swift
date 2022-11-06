//
//  PairColorService.swift
//  BsuirScheduleApp
//
//  Created by Nikita Prokhorchuk on 31.10.22.
//  Copyright © 2022 Saute. All rights reserved.
//

import SwiftUI

public class PairColorService: ObservableObject {
    public static let shared = PairColorService()
    
    private let userDefaults = UserDefaults.standard

    private init() {
        userDefaults.register(
            defaults: Dictionary(
                uniqueKeysWithValues: PairViewForm.allCases
                    .map { (key(for: $0), $0.defaultColor.rawValue) }
            )
        )
    }
    
    public func saveColor(_ color: PairFormColor, for form: PairViewForm) {
        userDefaults.set(color.rawValue, forKey: key(for: form))
    }
    
    public func getColor(for form: PairViewForm) -> PairFormColor {
        guard let color = userDefaults.string(forKey: key(for: form)) else {
            assertionFailure("Failed to get color for \(form)")
            return .gray
        }
        
        guard let formColor = PairFormColor(rawValue: color) else {
            assertionFailure("Failed to decode pair form color \(color)")
            return .gray
        }
                
        return formColor
    }
    
    private func key(for form: PairViewForm) -> String {
        return "pair-form-color.\(form.rawValue)"
    }
}

private extension PairViewForm {
    var defaultColor: PairFormColor {
        switch self {
        case .lecture:
            return .green
        case .practice:
            return .red
        case .lab:
            return .yellow
        case .exam:
            return .purple
        case .unknown:
            return .gray
        }
    }
}
