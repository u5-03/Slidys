//
//  Untitled.swift
//  SlidysCore
//
//  Created by yugo.sugiyama on 2025/02/19.
//

import Foundation

struct Todo: Identifiable {
    let id: UUID
    let title: String
    let description: String
    let tags: [String]
    let isDone: Bool
    let limitDate: Date
    let createdAt: Date

    var displayLimitDate: String {
        let calendar = Calendar.current
        if calendar.isDateInToday(limitDate) {
            return "今日"
        } else if calendar.isDateInTomorrow(limitDate) {
            return "明日"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy/MM/dd"
            return formatter.string(from: limitDate)
        }
    }

    var isDueOver: Bool {
        let calendar = Calendar.current
        let todayStart = calendar.startOfDay(for: Date())
        let limitStart = calendar.startOfDay(for: limitDate)
        return limitStart < todayStart
    }

    func copy(
        id: UUID? = nil,
        title: String? = nil,
        description: String? = nil,
        tags: [String]? = nil,
        isDone: Bool? = nil,
        limitDate: Date? = nil,
        createdAt: Date? = nil
    ) -> Todo {
        Todo(
            id: id ?? self.id,
            title: title ?? self.title,
            description: description ?? self.description,
            tags: tags ?? self.tags,
            isDone: isDone ?? self.isDone,
            limitDate: limitDate ?? self.limitDate,
            createdAt: createdAt ?? self.createdAt
        )
    }
}

extension Todo {
    static var mock: Todo {
        return Todo(
            id: UUID(),
            title: "Title",
            description: "description",
            tags: ["Tag1", "Tag2"],
            isDone: Bool.random(),
            limitDate: .now,
            createdAt: .now
        )
    }
}
