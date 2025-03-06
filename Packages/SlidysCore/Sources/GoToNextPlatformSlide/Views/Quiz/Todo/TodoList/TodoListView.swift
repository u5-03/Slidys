//
//  TodoListView.swift
//  SlidysCore
//
//  Created by yugo.sugiyama on 2025/02/19.
//

import SwiftUI
import SlidesCore

struct TodoListView: View {
    private let viewModel = TodoListViewModel()

    var body: some View {
        List {
            ForEach(viewModel.todoList) { todo in
                todoItemView(todo: todo)
                    .listRowSeparatorTint(.gray)
            }
        }
        .scrollContentBackground(.hidden)
        .background(.white)
        .preferredColorScheme(.light)
    }
}

private extension TodoListView {
    func todoItemView(todo: Todo) -> some View {
        HStack(spacing: 12) {
            Group {
                todo.isDone ? Image(systemName: "checkmark.circle").resizable()
                    : Image(systemName: "circle").resizable()
            }
            .frame(width: 32, height: 32)
            .onTapGesture {
                viewModel.switchDoneStatus(id: todo.id, willDone: !todo.isDone)
            }
            VStack(alignment: .leading) {
                Text(todo.title)
                    .strikethrough(todo.isDone)
                    .font(.system(size: 20))
                    .foregroundStyle(Color.black)
                Text(makeAttributedString(text: todo.description))
                    .lineLimit(nil)
                    .strikethrough(todo.isDone)
                    .font(.system(size: 16))
                    .foregroundStyle(Color.gray)
                FlowLayout(spacing: 2) {
                    ForEach(todo.tags, id: \.self) { tag in
                        Text(tag)
                            .foregroundStyle(.black)
                            .font(.system(size: 12))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 8)
                            .background(Color.green.opacity(0.2))
                            .cornerRadius(8)
                    }
                }
                HStack {
                    Text("期限:")
                        .font(.system(size: 14))
                        .foregroundStyle(.black)
                    if todo.isDueOver {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 16)
                            .foregroundStyle(.red)
                    }
                    Text(todo.displayLimitDate)
                        .font(.system(size: 12))
                        .foregroundStyle(todo.isDueOver ? .red : Color.black)
                    Spacer()
                }
            }
        }
    }
}

private extension TodoListView {
    func makeAttributedString(text: String) -> AttributedString {
        var attributedString = AttributedString(text)
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)

        let matches = detector.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count))

        for match in matches {
            guard let range = Range(match.range, in: text),
                  let attributedRange = Range(range, in: attributedString) else { continue }
            let url = text[range]
            if let url = URL(string: String(url)) {
                attributedString[attributedRange].link = url
            }
        }
        return attributedString
    }
}


#Preview {
    TodoListView()
}
