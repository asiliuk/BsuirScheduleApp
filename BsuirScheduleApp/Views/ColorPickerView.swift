//
//  ColorCoder.swift
//  BsuirScheduleApp
//
//  Created by Nikita Prokhorchuk on 9.09.22.
//  Copyright © 2022 Saute. All rights reserved.
//

import SwiftUI
import BsuirUI

struct ColorPickerView: View {
    var body: some View {
        Section(header: Text("screen.about.colors.section.header")) {
            ForEach(PairViewForm.allCases, id: \.self) { form in
                PickerView(form: form)
            }
        }
    }
}

private struct PickerView: View {
    let form: PairViewForm
    @State private var color: CodableColor
    
    init(form: PairViewForm) {
        self.form = form
        self.color = CodableColor(color: form.color)!
    }
    
    var body: some View {
        Picker(form.name, selection: $color) {
            ForEach(CodableColor.allCases, id: \.self) { color in
                ColorView(color: Color(codableColor: color))
            }
        }.onChange(of: color) { selectedColor in
            let userDefaults = UserDefaults.standard
            let coder = ColorCoder()
            let encodedColor = try! coder.encodeColor(Color(codableColor: color))
            
            switch form {
            case .lecture:
                userDefaults.set(encodedColor, forKey: "lectureColor")
            case .practice:
                userDefaults.set(encodedColor, forKey: "practiceColor")
            case .lab:
                userDefaults.set(encodedColor, forKey: "labColor")
            case .exam:
                userDefaults.set(encodedColor, forKey: "examColor")
            case .unknown:
                userDefaults.set(encodedColor, forKey: "unknownColor")
            }
        }
    }
}

private struct ColorView: View {
    let color: Color
    
    var body: some View {
        Group {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
        }
        .frame(width: 30, height: 30)
        .foregroundColor(color)
    }
}
