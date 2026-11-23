import SwiftUI

extension LocalizedStringResource {
    public static let subgroupPickerTitle: LocalizedStringResource = .viewSubgroupPickerTitle
}

extension Label<Text, Image> {
    public static let allSubgroups = Label(
        .viewSubgroupPickerAllSubgroupsTitle,
        systemImage: "person.2"
    )

    public static func subgroup(_ subgroup: Int) -> Label {
        Label(
            .viewSubgroupPickerSubgroupTitle(String(describing: subgroup)),
            systemImage: "person"
        )
    }
}
