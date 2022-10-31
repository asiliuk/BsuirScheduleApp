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
        
        let color = PairColorService.shared.getColor(for: form)
        self.color = CodableColor(color: color) ?? .gray
    }
    
    var body: some View {
        Picker(form.name, selection: $color) {
            ForEach(CodableColor.allCases, id: \.self) { color in
                ColorView(color: Color(codableColor: color))
            }
        }
        .onChange(of: color) { selectedColor in
            PairColorService.shared.saveColor(color: selectedColor, for: form)
        }
    }
}

struct ColorView: View {
    let color: Color
    @ScaledMetric(relativeTo: .body) private var size: CGFloat = 34
    @State private var isOpen = false
    
    var body: some View {
        HStack {
            Image(uiImage: iconImage)
                .resizable()
                .frame(width: size, height: size)
            if isOpen { Text(LocalizedStringKey(stringLiteral: "color.\(color.description)")) }
        }.onAppear {
            isOpen = true
        }
    }
    
    private var iconImage: UIImage {
        UIGraphicsImageRenderer(size: CGSize(width: size, height: size)).image { context in
            UIBezierPath(roundedRect: context.format.bounds, cornerRadius: (8 / 34) * size).addClip()
            image?.draw(in: context.format.bounds)
        }
    }
    
    private var image: UIImage? {
        UIImage(color: UIColor(color))
    }
}
