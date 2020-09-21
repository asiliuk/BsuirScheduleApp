import Intents
import BsuirApi
import Combine

class IntentHandler: INExtension, ConfigurationIntentHandling {
    func resolveGroupNumber(for intent: ConfigurationIntent, with completion: @escaping (ConfigurationGroupNumberResolutionResult) -> Void) {
        groupsRequestCancellable = requestManager
            .request(BsuirTargets.Groups())
            .map { $0.sorted { $0.name < $1.name } }
            .map { $0.map { ScheduleIdentifier(identifier: String($0.id), display: $0.name) } }
            .sink(
                receiveFailure: { _ in completion(.unsupported(forReason: .failed)) },
                receiveValue: { completion(.disambiguation(with: $0)) }
            )
    }

    func resolveLecturer(for intent: ConfigurationIntent, with completion: @escaping (ConfigurationLecturerResolutionResult) -> Void) {
        lecturersRequestCancellable = requestManager
            .request(BsuirTargets.Employees())
            .map { $0.sorted { $0.fio < $1.fio } }
            .map { $0.map { ScheduleIdentifier(identifier: String($0.id), display: $0.fio) } }
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
    private let requestManager = RequestsManager.bsuir()
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
