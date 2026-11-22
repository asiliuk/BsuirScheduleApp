import SwiftUI
import ScheduleCore
import BsuirUI

struct ScheduleDisplayTypePickerMenu: View {
    @Binding var scheduleType: ScheduleDisplayType
    
    var body: some View {
        Menu {
            ScheduleDisplayTypePicker(scheduleType: $scheduleType)
        } label: {
            Label {
                Text(ScheduleDisplayType.pickerTitle)
            } icon: {
                Image(systemName: scheduleType.imageName)
            }
        }
        .tint(.primary)
    }
}

struct ScheduleDisplayTypePicker: View {
    @Binding var scheduleType: ScheduleDisplayType
    
    var body: some View {
        Picker(ScheduleDisplayType.pickerTitle, selection: $scheduleType) {
            ForEach(ScheduleDisplayType.allCases, id: \.self) { scheduleType in
                Label(scheduleType.title, systemImage: scheduleType.imageName)
            }
        }
        .tint(nil)
    }
}
