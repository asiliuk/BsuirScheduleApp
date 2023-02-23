import SwiftUI
import BsuirCore
import SettingsFeature
import GroupsFeature
import LecturersFeature
import EntityScheduleFeature
import ComposableArchitecture
import ComposableArchitectureUtils

struct CompactRootView: View {
    let store: StoreOf<AppFeature>

    var body: some View {
        WithViewStore(store, observe: \.selection) { viewStore in
            TabView(selection: viewStore.binding(get: { $0 }, send: AppFeature.Action.setSelection)) {

                PinnedTabView(
                    store: store.scope(
                        state: \.pinnedTab,
                        action: AppFeature.Action.pinnedTab
                    )
                )
                .tag(CurrentSelection.pinned)

                GroupsFeatureTab(
                    store: store.scope(
                        state: \.groups,
                        action: AppFeature.Action.groups
                    )
                )
                .tag(CurrentSelection.groups)

                LecturersFeatureTab(
                    store: store.scope(
                        state: \.lecturers,
                        action: AppFeature.Action.lecturers
                    )
                )
                .tag(CurrentSelection.lecturers)

                SettingsFeatureTab(
                    store: store.scope(
                        state: \.settings,
                        action: AppFeature.Action.settings
                    )
                )
                .tag(CurrentSelection.settings)
            }
        }
    }
}

private struct GroupsFeatureTab: View {
    let store: StoreOf<GroupsFeature>

    var body: some View {
        NavigationStack {
            GroupsFeatureView(store: store)
                .navigationBarTitleDisplayMode(.inline)
        }
        .tabItem { GroupsLabel() }
    }
}

private struct LecturersFeatureTab: View {
    let store: StoreOf<LecturersFeature>

    var body: some View {
        NavigationStack {
            LecturersFeatureView(store: store)
                .navigationBarTitleDisplayMode(.inline)
        }
        .tabItem { LecturersLabel() }
    }
}

private struct SettingsFeatureTab: View {
    let store: StoreOf<SettingsFeature>

    var body: some View {
        WithViewStore(store, observe: \.path) { viewStore in
            NavigationStack(path: viewStore.binding(send: { .view(.setPath($0)) })) {
                SettingsFeatureView(store: store)
                    .navigationBarTitleDisplayMode(.inline)

            }
        }
        .tabItem { SettingsLabel() }
    }
}
import BsuirUI

struct SomePreview: PreviewProvider {
    struct Lecturer: Identifiable {
        let id = UUID()
        let image: String
        let name: String
        let degree: String?
    }
    
    struct LecturerCell: View {
        let image: String
        let name: String
        let degree: String?
        let photoAction: () -> Void
        @State var cellTapped = false

        var body: some View {
            Button(action: { cellTapped.toggle() }) {
                HStack {
                    Button {
                        photoAction()
                    } label: {
                        Avatar(url: URL(string: image), baseSize: 60)
                            .overlay(alignment: .bottomTrailing) {
                                Image(systemName: "magnifyingglass.circle.fill")
                                    .font(.title3)
                                    .foregroundStyle(Color.primary, Color(uiColor: .secondarySystemGroupedBackground))
                            }
                    }
                    VStack(alignment: .leading) {
                        Text(name)
                        degree.map(Text.init(verbatim:))?
                            .font(.caption)
                    }

                    Spacer()

                    Image(systemName: "chevron.forward")
                        .font(.footnote.bold())
                        .foregroundColor(.secondary)
                }
                .foregroundColor(.primary)
            }
        }
    }

    struct PairBottomDetails<Content: View>: View {
        @State var detent: PresentationDetent = .height(250)
        @ViewBuilder var content: Content

        var body: some View {
            ModalNavigationStack {
                content
            }
//            MARK: If image is open, keep only .large detent, image is not really beautiful in .height(250)
//            .presentationDetents(imagePresent ? [.large] : [.height(250), .large], selection: $detent)
            .presentationDetents([.height(250), .large], selection: $detent)
            .presentationDragIndicator(.hidden)
            .scrollIndicators(.never)
        }
    }
    
    struct PairDetailsView: View {
        let lecturers: [Lecturer]
        let subjectName: String
        let subjectFullName: String
        let pairType: String
        let subgroups: String
        let auditories: String
        let days: String
        let weeks: String
        let note: String?
        
        @State private var imagePresent = false
        @State private var imageURL = ""
        
        var body: some View {
            List {
                Section {
                    ForEach(lecturers) { lecturer in
                        LecturerCell(
                            image: lecturer.image,
                            name: lecturer.name,
                            degree: lecturer.degree,
                            photoAction: {
                                imageURL = lecturer.image
                                imagePresent = true
                            }
                        )
                    }
                }
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                
                Section("Детали") {
                    Text(subjectFullName)
                        .font(.title3.bold())
                    
                    LabeledContent("Тип") { Text(pairType) }
                    LabeledContent("Подгруппы") { Text(subgroups) }
                    LabeledContent("Аудитории") { Text(auditories) }
                    LabeledContent("Дни") { Text(days) }
                    LabeledContent("Недели") { Text(weeks) }
                    
                    if note != nil {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Заметки")
                            Text(note!)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .padding(.top, -24)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if !imagePresent {
                    ToolbarItem(placement: .principal) {
                        VStack {
                            Text(subjectName).font(.headline)
                            Text((Date.now..<Date.now.addingTimeInterval(3600)).formatted())
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .overlay {
                if imagePresent {
                    imageDetailsOverlay
                }
            }
            .animation(.easeInOut(duration: 0.1), value: imagePresent)
        }
        
        @GestureState private var imageDraggingOffset: CGSize = .zero
        @State private var imageScale: CGFloat = 1
        @State private var backgroundOpacity: Double = 1
        
        private var imageDetailsOverlay: some View {
            ZStack {
                Color.black
                    .ignoresSafeArea()
                    .opacity(backgroundOpacity)
                    .onTapGesture { imagePresent = false }
                
                FullScreenAvatar(url: URL(string: imageURL))
                    .offset(y: imageDraggingOffset.height)
                    .scaleEffect(imageScale > 1 ? imageScale : 1)
                    .simultaneousGesture(DragGesture().updating($imageDraggingOffset) { value, outValue, _ in
                        outValue = value.translation
                    }.onEnded { value in
                        var predictedLocation = value.predictedEndLocation.y
                        
                        if predictedLocation < 0 {
                            predictedLocation = -predictedLocation
                        }
                        
                        if predictedLocation > 250 {
                            imagePresent = false
                        }
                        
                        backgroundOpacity = 1
                    })
                // MARK: Zoom to scale
                //                    .simultaneousGesture(MagnificationGesture().onChanged { value in
                //                        imageScale = value
                //                    }.onEnded { _ in
                //                        withAnimation(.spring()) {
                //                            imageScale = 1
                //                        }
                //                    })
                // MARK: Double tap to scale
                //                    .simultaneousGesture(TapGesture(count: 2).onEnded {
                //                        withAnimation {
                //                            imageScale = imageScale > 1 ? 1 : 4
                //                        }
                //                    })
                    .onChange(of: imageDraggingOffset) { newValue in
                        let screenHalfHeight = UIScreen.main.bounds.height / 2 // TODO: Change UIScreen.main due to deprecation
                        let progress = newValue.height / screenHalfHeight
                        
                        withAnimation(.default) {
                            backgroundOpacity = 1 - (progress < 0 ? -progress : progress)
                        }
                    }
                    .animation(.easeInOut(duration: 0.1), value: imageDraggingOffset)
            }
        }
    }
    
    struct TestView: View {
        @State var bottomSheetVisible = true

        var body: some View {
            Button("Show") {
                bottomSheetVisible.toggle()
            }
            .buttonStyle(.borderedProminent)
            .sheet(isPresented: $bottomSheetVisible) {
                PairBottomDetails {
                    PairDetailsView(
                        lecturers: [
                            Lecturer(
                                image: "https://iis.bsuir.by/api/v1/employees/photo/515644",
                                name: "Фещенко Артём Александрович",
                                degree: nil
                            ),
                            Lecturer(
                                image: "https://iis.bsuir.by/api/v1/employees/photo/511968",
                                name: "Ролич Олег Чеславович",
                                degree: "кандидат технических наук"
                            )
                        ],
                        subjectName: "ПиРИС",
                        subjectFullName: "Проектирование и разработка информационных систем",
                        pairType: "Лекция",
                        subgroups: "--",
                        auditories: "157к 2",
                        days: "Чт, Пт",
                        weeks: "1, 3",
                        note: "Это какая-то совершенно не нужная, но очень длинная и важная заметка"
                    )
                }
            }
        }
    }

    static var previews: some View {
        TestView()
    }
}
