import SwiftUI

struct ScheduleDisplayTypePickerMenu: View {
    @Binding var scheduleType: ScheduleDisplayType
    
    var body: some View {
        Menu {
            Picker("screen.schedule.scheduleTypePicker.title", selection: $scheduleType) {
                ForEach(ScheduleDisplayType.allCases, id: \.self) { scheduleType in
                    Label(scheduleType.title, systemImage: scheduleType.imageName)
                }
            }
        } label: {
            Label("screen.schedule.scheduleTypePicker.title", systemImage: scheduleType.imageName)
        }
    }
}
