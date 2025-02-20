//
//  TodoListViewModel.swift
//  SlidysCore
//
//  Created by yugo.sugiyama on 2025/02/19.
//

import Foundation
import Observation
import SlidesCore

@Observable
final class TodoListViewModel: ObservableObject {
    private static let tagList = [
        "Go", "Web", "Unity", "Swift", "Android", "Flutter", "Ruby", "Data/ML", "Vim"
    ]
    private(set) var todoList: [Todo] = [
        .mock.copy(tags: tagList.randomSubset, limitDate: .now.offsetDays(offset: -1)),
        .mock.copy(description: "TechConのイベントのURLはこちらです\n https://techcon2025.dena.dev", tags: tagList.randomSubset),
        .mock.copy(tags: tagList.randomSubset, limitDate: .now.offsetDays(offset: 1)),
        .mock.copy(tags: tagList.randomSubset, limitDate: .now.offsetDays(offset: 5)),
    ]

    func addTodo(todo: Todo) {
        todoList.append(todo)
    }

    func removeTodo(id: UUID) {
        todoList.removeAll(where: { $0.id == id })
    }

    func switchDoneStatus(id: UUID, willDone: Bool) {
        let targetId: UUID = id
        if let index = todoList.firstIndex(where: { $0.id == targetId }) {
            // copyWithで必要なプロパティのみ更新（ここでは例としてtitleを変更）
            todoList[index] = todoList[index].copy(isDone: willDone)
        }
    }
}
