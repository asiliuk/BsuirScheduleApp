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
    
    @State private var color: PairFormColor
    
    init(form: PairViewForm) {
        self.form = form
        self.color = PairColorService.shared.getColor(for: form)
    }
    
    var body: some View {
        Picker(form.name, selection: $color) {
            ForEach(PairFormColor.allCases, id: \.self) { color in
                ColorView(color: color.color, name: color.name)
            }
        }
        .onChange(of: color) { selectedColor in
            PairColorService.shared.saveColor(selectedColor, for: form)
        }
    }
}

struct ColorView: View {
    let color: Color
    let name: LocalizedStringKey
    @ScaledMetric(relativeTo: .body) private var size: CGFloat = 24
    @State private var isOpen = false
    
    var body: some View {
        HStack {
            Image(uiImage: iconImage)
                .resizable()
                .frame(width: size, height: size)
            if isOpen { Text(name) }
        }.onAppear {
            isOpen = true
        }
    }
    
    private var iconImage: UIImage {
        UIGraphicsImageRenderer(size: CGSize(width: size, height: size)).image { context in
            UIColor(color).setFill()
            UIBezierPath(roundedRect: context.format.bounds, cornerRadius: (8 / 34) * size).fill()
        }
    }
}
