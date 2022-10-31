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
    
    private init() { }
    
    public func saveColor(color: CodableColor, for form: PairViewForm) {
        let userDefaults = UserDefaults.standard
        let coder = ColorCoder()
        
        var encodedColor: Data?
        
        do {
            encodedColor = try coder.encodeColor(Color(codableColor: color))
        } catch {
            print(error)
        }
        
        userDefaults.set(encodedColor, forKey: "\(form)Color")
    }
    
    public func getColor(for form: PairViewForm) -> Color {
        let userDefaults = UserDefaults.standard
        let coder = ColorCoder()
        
        guard let colorData = userDefaults.data(forKey: "\(form)Color") else { return form.defaultColor }
        
        do {
            return try coder.decodeColor(from: colorData)
        } catch {
            print(error)
        }
        
        return form.defaultColor
    }
}
