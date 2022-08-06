import Intents
import BsuirApi
import Combine

class IntentHandler: INExtension, ConfigurationIntentHandling {
    func resolveGroupName(for intent: ConfigurationIntent, with completion: @escaping (ConfigurationGroupNameResolutionResult) -> Void) {
        groupsRequestCancellable = requestManager
            .request(BsuirIISTargets.Groups())
            .map { groups in
                intent.groupName.map { name in
                    groups.filter { $0.name.starts(with: name.displayString) }
                } ?? groups
            }
            .map { $0.sorted { $0.name < $1.name } }
            .map { $0.map { ScheduleIdentifier(identifier: $0.name, display: $0.name) } }
            .sink(
                receiveFailure: { _ in completion(.unsupported(forReason: .failed)) },
                receiveValue: { completion(.disambiguation(with: $0)) }
            )
    }

    func resolveLecturerUrlId(for intent: ConfigurationIntent, with completion: @escaping (ConfigurationLecturerUrlIdResolutionResult) -> Void) {
        lecturersRequestCancellable = requestManager
            .request(BsuirIISTargets.Employees())
            .map { lecturers in
                intent.lecturerUrlId.map { urlId in
                    lecturers.filter { $0.fio.contains(urlId.displayString) }
                } ?? lecturers
            }
            .map { $0.sorted { $0.fio < $1.fio } }
            .map { $0.map { ScheduleIdentifier(identifier: $0.urlId, display: $0.fio) } }
            .sink(
                receiveFailure: { _ in completion(.unsupported(forReason: .failed)) },
                receiveValue: { completion(.disambiguation(with: $0)) }
            )
    }

    override func handler(for intent: INIntent) -> Any {
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.
        
        return self
    }

    private var groupsRequestCancellable: AnyCancellable?
    private var lecturersRequestCancellable: AnyCancellable?
    private let requestManager = RequestsManager.iisBsuir()
}

private extension Publisher {
    func sink(receiveFailure: @escaping (Failure) -> Void, receiveValue: @escaping (Output) -> Void) -> AnyCancellable {
        sink(
            receiveCompletion: { completion in
                switch completion {
                case .finished: break
                case let .failure(error): receiveFailure(error)
                }
            },
            receiveValue: receiveValue
        )
    }
}
