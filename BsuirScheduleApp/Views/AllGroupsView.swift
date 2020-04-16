//
//  AllGroupsView.swift
//  BsuirScheduleApp
//
//  Created by Anton Siliuk on 9/28/19.
//  Copyright © 2019 Saute. All rights reserved.
//

import SwiftUI
import Foundation

struct AllGroupsView: View {
    
    @State private var searchTerm: String = ""
    @ObservedObject var screen: AllGroupsScreen

    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text:$searchTerm, placeholder: "Найти группу")
                ContentStateView(content: screen.state)
                { value in
                    List(self.searchTerm.isEmpty ? value : value.filter({$0.name.starts(with: self.searchTerm)}))
                    { group in
                        NavigationLink(destination: ScheduleView(screen: self.screen.screen(for: group))) {
                            Text(group.name)
                        }
                    }
                }
                .navigationBarTitle("Все группы")
            }
            .onAppear(perform: screen.load)
        }
    }

    struct AllGroupsView_Previews: PreviewProvider {
        static var previews: some View {
            /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
        }
    }
}
