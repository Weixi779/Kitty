import SwiftUI
import AppKit
import ComposableArchitecture

struct JsonToolView: View {
    let store: StoreOf<JsonToolReducer>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(alignment: .leading, spacing: 12) {
                modePicker(viewStore)

                HStack(spacing: 16) {
                    textEditor(
                        title: "Input (\(viewStore.inputCount))",
                        text: viewStore.binding(get: \.inputText, send: JsonToolReducer.Action.setInput),
                        isEditable: true
                    )
                    textEditor(
                        title: "Output (\(viewStore.outputCount))",
                        text: .constant(viewStore.outputText),
                        isEditable: false
                    )
                }
                .frame(minHeight: 280)

                if let error = viewStore.errorMessage, !error.isEmpty {
                    Text(error)
                        .font(.footnote)
                        .foregroundColor(.red)
                }

                HStack(spacing: 12) {
                    Button("Run") {
                        viewStore.send(.run)
                    }
                    .keyboardShortcut(.return, modifiers: [.command])

                    Button("Clear") {
                        viewStore.send(.clear)
                    }

                    Button("Copy Output") {
                        copyToClipboard(viewStore.outputText)
                        viewStore.send(.copyOutput)
                    }
                    .disabled(viewStore.outputText.isEmpty)
                }
                .padding(.top, 4)

                Spacer()
            }
            .padding(16)
        }
    }

    @ViewBuilder
    private func modePicker(_ viewStore: ViewStore<JsonToolReducer.State, JsonToolReducer.Action>) -> some View {
        Picker("Mode", selection: viewStore.binding(get: \.mode, send: JsonToolReducer.Action.setMode)) {
            ForEach(JsonTransformMode.allCases, id: \.self) { mode in
                Text(label(for: mode)).tag(mode)
            }
        }
        .pickerStyle(.segmented)
        .padding(.bottom, 4)
    }

    @ViewBuilder
    private func textEditor(title: String, text: Binding<String>, isEditable: Bool) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.headline)
            TextEditor(text: text)
                .font(.system(.body, design: .monospaced))
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.2))
                )
                .disabled(!isEditable)
        }
    }

    private func label(for mode: JsonTransformMode) -> String {
        switch mode {
        case .format: return "Format"
        case .minify: return "Minify"
        case .escape: return "Escape"
        case .unescape: return "Unescape"
        }
    }

    private func copyToClipboard(_ text: String) {
        #if os(macOS)
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
        #endif
    }
}

#Preview {
    let store = Store(initialState: JsonToolReducer.State()) {
        JsonToolReducer()
    } withDependencies: {
        $0.jsonTransformUseCase = PreviewUseCase()
    }

    return JsonToolView(store: store)
}

private struct PreviewUseCase: JsonTransformUseCase {
    func execute(_ request: JsonTransformRequest) -> JsonTransformResult {
        JsonTransformResult(output: "preview-output (\(request.mode))", isValidJson: true, errorDescription: nil)
    }
}
