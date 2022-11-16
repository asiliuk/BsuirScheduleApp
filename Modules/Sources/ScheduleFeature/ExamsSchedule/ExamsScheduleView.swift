import SwiftUI
import BsuirUI
import BsuirApi
import ComposableArchitecture
import ComposableArchitectureUtils

struct ExamsScheduleView: View {
    let store: StoreOf<ExamsScheduleFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            List {
                Section("screen.schedule.unsupportedExams.title") {
                    VStack(alignment: .leading) {
                        Text("screen.schedule.unsupportedExams.subject").font(.headline)
                        Text("screen.schedule.unsupportedExams.auditory").font(.body)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("screen.schedule.unsupportedExams.subject2").font(.headline)
                        Text("https://github.com/asiliuk/BsuirScheduleApp").font(.body)
                    }
                }
            }
        }
    }
}
