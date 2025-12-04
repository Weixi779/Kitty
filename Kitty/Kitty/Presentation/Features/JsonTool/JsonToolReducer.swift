import ComposableArchitecture
import Foundation

enum JsonTransformUseCaseKey: DependencyKey {
    static let liveValue: any JsonTransformUseCase = {
        fatalError("JsonTransformUseCase liveValue is not set. Inject in the app target.")
    }()
}

extension DependencyValues {
    var jsonTransformUseCase: any JsonTransformUseCase {
        get { self[JsonTransformUseCaseKey.self] }
        set { self[JsonTransformUseCaseKey.self] = newValue }
    }
}

struct JsonToolReducer: Reducer {
    init() {}

    @Dependency(\.jsonTransformUseCase) private var useCase

    struct State: Equatable, Sendable {
        var mode: JsonTransformMode = .format
        var inputText: String = ""
        var outputText: String = ""
        var errorMessage: String?

        var inputCount: Int { inputText.count }
        var outputCount: Int { outputText.count }

        init() {}
    }

    enum Action: Equatable, Sendable {
        case setMode(JsonTransformMode)
        case setInput(String)
        case run
        case clear
        case copyOutput
        case _setResult(JsonTransformResult)
    }

    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case let .setMode(mode):
            state.mode = mode
            return .none

        case let .setInput(text):
            state.inputText = text
            return .none

        case .clear:
            state.inputText = ""
            state.outputText = ""
            state.errorMessage = nil
            return .none

        case .run:
            let request = JsonTransformRequest(rawText: state.inputText, mode: state.mode)
            let result = useCase.execute(request)
            return .send(._setResult(result))

        case ._setResult(let result):
            state.outputText = result.output
            state.errorMessage = result.errorDescription
            return .none

        case .copyOutput:
            // UI handles clipboard.
            return .none
        }
    }
}
