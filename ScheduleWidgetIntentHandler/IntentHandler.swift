import Intents
import BsuirApi
import Combine

class IntentHandler: INExtension, ConfigurationIntentHandling {
    func resolveGroupName(for intent: ConfigurationIntent, with completion: @escaping (ConfigurationGroupNameResolutionResult) -> Void) {
        groupsRequest = Task {
            do {
                let shceduleIdentifiers = try await apiCLient.groups()
                    .filter { group in
                        guard let search = intent.groupName else { return true }
                        return group.name.contains(search.displayString)
                    }
                    .sorted(by: { $0.name < $1.name })
                    .map { ScheduleIdentifier(identifier: $0.name, display: $0.name) }

                completion(.disambiguation(with: shceduleIdentifiers))
            } catch {
                completion(.unsupported(forReason: .failed))
            }
        }
    }

    func resolveLecturerUrlId(for intent: ConfigurationIntent, with completion: @escaping (ConfigurationLecturerUrlIdResolutionResult) -> Void) {
        lecturersRequest = Task {
            do {
                let shceduleIdentifiers = try await apiCLient.lecturers()
                    .filter { lector in
                        guard let search = intent.lecturerUrlId else { return true }
                        return lector.fio.contains(search.displayString)
                    }
                    .sorted(by: { $0.fio < $1.fio })
                    .map { ScheduleIdentifier(identifier: $0.urlId, display: $0.fio) }

                completion(.disambiguation(with: shceduleIdentifiers))
            } catch {
                completion(.unsupported(forReason: .failed))
            }
        }
    }

    override func handler(for intent: INIntent) -> Any {
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.
        
        return self
    }

    deinit {
        groupsRequest?.cancel()
        lecturersRequest?.cancel()
    }

    private var groupsRequest: Task<Void, Never>? {
        didSet { oldValue?.cancel() }
    }
    private var lecturersRequest: Task<Void, Never>? {
        didSet { oldValue?.cancel() }
    }
    private let apiCLient = ApiClient.live
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
