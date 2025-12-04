import ComposableArchitecture
import Testing
@testable import Kitty

struct JsonToolReducerTests {
    @Test
    func runSuccess() async {
        let store = TestStore(initialState: .init()) {
            JsonToolReducer()
        } withDependencies: {
            $0.jsonTransformUseCase = StubUseCase { request in
                .init(output: "ok-\(request.mode)", isValidJson: true, errorDescription: nil)
            }
        }

        await store.send(.setInput("{\"a\":1}")) {
            $0.inputText = "{\"a\":1}"
        }
        await store.send(.run)
        await store.receive(._setResult(.init(output: "ok-format", isValidJson: true, errorDescription: nil))) {
            $0.outputText = "ok-format"
            $0.errorMessage = nil
        }
    }

    @Test
    func runFailureSetsError() async {
        let store = TestStore(initialState: .init()) {
            JsonToolReducer()
        } withDependencies: {
            $0.jsonTransformUseCase = StubUseCase { _ in
                .init(output: "", isValidJson: false, errorDescription: "bad")
            }
        }

        await store.send(.run)
        await store.receive(._setResult(.init(output: "", isValidJson: false, errorDescription: "bad"))) {
            $0.outputText = ""
            $0.errorMessage = "bad"
        }
    }
}

private struct StubUseCase: JsonTransformUseCase {
    let handler: (JsonTransformRequest) -> JsonTransformResult
    func execute(_ request: JsonTransformRequest) -> JsonTransformResult {
        handler(request)
    }
}
