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
                SearchBar(text:$searchTerm)
                ContentStateView(content: screen.state)
                { value in
                    List(self.searchTerm.isEmpty ? value : self.filterList(value: value))
                    { group in
                        NavigationLink(destination: ScheduleView(screen: self.screen.screen(for: group))) {
                            Text(group.name)
                        }
                    }
                }
                .navigationBarTitle("Все группы")
                Spacer()
            }
            .onAppear(perform: screen.load)
        }
    }
    
    private func filterList(value: [AllGroupsScreenGroup]) -> [AllGroupsScreenGroup] {
        var newValue:[AllGroupsScreenGroup] = value
        for (indexSearch, char) in searchTerm.enumerated() {
            newValue = newValue.filter({Array($0.name)[indexSearch] == char})
        }
        return newValue
    }
    
    struct AllGroupsView_Previews: PreviewProvider {
        static var previews: some View {
            /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
        }
    }
}
