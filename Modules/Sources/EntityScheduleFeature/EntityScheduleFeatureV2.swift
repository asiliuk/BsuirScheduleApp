import Foundation
import ComposableArchitecture

@Reducer
public enum EntityScheduleFeatureV2 {
    case group(GroupScheduleFeature)
    case lector(LectorScheduleFeature)
}
