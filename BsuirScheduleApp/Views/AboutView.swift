//
//  AboutView.swift
//  BsuirScheduleApp
//
//  Created by mac on 6/20/20.
//  Copyright © 2020 Saute. All rights reserved.
//

import SwiftUI
import Foundation

struct AboutView: View {
    var body: some View {
        VStack {
            ScheduleInfoView()
                .padding(EdgeInsets(top: 10, leading: 15, bottom: 0, trailing: 15))
            InfoView()
                .padding(EdgeInsets(top: 10, leading: 15, bottom: 0, trailing: 15))
            Spacer()
        }
        .navigationBarTitle("Информация")
    }
}

struct ScheduleInfoView: View {
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                PairTypeView(type: "Лекция", color: .green)
                    .padding([.leading, .top], 20)
                PairTypeView(type: "Лабораторная работа", color: .yellow)
                    .padding(.leading, 20)
                PairTypeView(type: "Практическая работа", color: .red)
                    .padding(.leading, 20)
            }
            PairCell(from: "начало", to: "конец", subject: "Предмет", weeks: "неделя", note: "Кабинет - корпус", form: .practice, progress: PairProgress(constant: 0.5))
                .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                .fixedSize(horizontal: false, vertical: true)
                .overlay(RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1))
        }
    }
}

struct InfoView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack() {
                Text("О приложении")
                    .font(.headline)
                    .bold()
                Spacer()
            }
            VStack(alignment: .leading, spacing: 5) {
                Text("Версия 1.0")
                Button(action: {
                    guard let url = URL(string: "https://github.com/asiliuk/BsuirScheduleApp") else { return }
                    UIApplication.shared.open(url)
                }, label: {
                    Text("GitHub")
                        .underline()
                        .foregroundColor(.black)
                })
            }
        }
        .padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15))
        .overlay(RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1))
    }
}

struct PairTypeView: View {
    var type: String
    var color: Color

    var body: some View {
        HStack {
            color.frame(width: 30, height: 30)
                .clipShape(Circle())
            Text(type)
        }
    }
}
