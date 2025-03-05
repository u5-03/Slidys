//
//  DataChartView.swift
//  SlidysCore
//
//  Created by yugo.sugiyama on 2025/02/16.
//

import SwiftUI
import Charts
import SlidesCore

struct ChartData: Identifiable, Hashable {
    var id: Double {
        date.timeIntervalSince1970
    }

    let date: Date
    let startValue: Int
    let maxValue: Int
    let minValue: Int
    let endValue: Int
    let isPositive: Bool
}

struct DataChartView: View {
    var dataList: [ChartData] = [
        ChartData(date: .init(year: 2025, month: 1, day: 17),
                  startValue: 2782, maxValue: 2838, minValue: 2566, endValue: 2578, isPositive: true),
        ChartData(date: .init(year: 2025, month: 1, day: 20),
                  startValue: 2529, maxValue: 2610, minValue: 2525, endValue: 2536, isPositive: false),
        ChartData(date: .init(year: 2025, month: 1, day: 21),
                  startValue: 2565, maxValue: 2674, minValue: 2557, endValue: 2570, isPositive: false),

        ChartData(date: .init(year: 2025, month: 1, day: 22),
                  startValue: 2600, maxValue: 2654, minValue: 2583, endValue: 2631, isPositive: false),

        ChartData(date: .init(year: 2025, month: 1, day: 23),
                  startValue: 2598, maxValue: 2715, minValue: 2595, endValue: 2665, isPositive: false),

        ChartData(date: .init(year: 2025, month: 1, day: 24),
                  startValue: 2734, maxValue: 2929, minValue: 2706, endValue: 2760, isPositive: false),

        ChartData(date: .init(year: 2025, month: 1, day: 27),
                  startValue: 2760, maxValue: 2763, minValue: 2672, endValue: 2715, isPositive: true),

        ChartData(date: .init(year: 2025, month: 1, day: 28),
                  startValue: 2731, maxValue: 2794, minValue: 2706, endValue: 2723, isPositive: true),

        ChartData(date: .init(year: 2025, month: 1, day: 29),
                  startValue: 2735, maxValue: 2744, minValue: 2667, endValue: 2703, isPositive: true),

        ChartData(date: .init(year: 2025, month: 1, day: 30),
                  startValue: 2723, maxValue: 2827, minValue: 2722, endValue: 2820, isPositive: false),

        ChartData(date: .init(year: 2025, month: 1, day: 31),
                  startValue: 2828, maxValue: 2842, minValue: 2730, endValue: 2740, isPositive: true),

        ChartData(date: .init(year: 2025, month: 2, day: 3),
                  startValue: 2690, maxValue: 2837, minValue: 2675, endValue: 2826, isPositive: false),

        ChartData(date: .init(year: 2025, month: 2, day: 4),
                  startValue: 2834, maxValue: 2920, minValue: 2823, endValue: 2920, isPositive: false),

        ChartData(date: .init(year: 2025, month: 2, day: 5),
                  startValue: 2901, maxValue: 2953, minValue: 2868, endValue: 2945, isPositive: false),

        ChartData(date: .init(year: 2025, month: 2, day: 6),
                  startValue: 2940, maxValue: 3082, minValue: 2910, endValue: 3070, isPositive: false),

        ChartData(date: .init(year: 2025, month: 2, day: 7),
                  startValue: 3057, maxValue: 3132, minValue: 2997, endValue: 3032, isPositive: true),

        ChartData(date: .init(year: 2025, month: 2, day: 10),
                  startValue: 3501, maxValue: 3732, minValue: 3471, endValue: 3732, isPositive: false),

        ChartData(date: .init(year: 2025, month: 2, day: 12),
                  startValue: 3795, maxValue: 3976, minValue: 3475, endValue: 3594, isPositive: true),

        ChartData(date: .init(year: 2025, month: 2, day: 13),
                  startValue: 3541, maxValue: 3772, minValue: 3526, endValue: 3731, isPositive: false),

        ChartData(date: .init(year: 2025, month: 2, day: 14),
                  startValue: 3710, maxValue: 3842, minValue: 3655, endValue: 3681, isPositive: true)
    ]

    var body: some View {
        Chart {
            ForEach(dataList, id: \.self) { data in
                BarMark(
                    x: .value("Date", data.date.asString(withFormat: .monthDay)),
                    yStart: .value("value", data.minValue),
                    yEnd: .value("value", data.maxValue),
                    width: 4
                )
                .foregroundStyle(data.isPositive ? .red : .blue)
            }
            ForEach(dataList, id: \.self) { data in
                BarMark(
                    x: .value("Date", data.date.asString(withFormat: .monthDay)),
                    yStart: .value("value", data.startValue),
                    yEnd: .value("value", data.endValue),
                    width: 12
                )
                .cornerRadius(1)
                .foregroundStyle(data.isPositive ? .red : .blue)
            }
        }
        .chartYScale(domain: 2000...4400)
        .chartYAxis {
            AxisMarks { _ in
                AxisValueLabel()
                    .font(.system(size: 16))
                    .foregroundStyle(.black)
            }
        }
        .chartXAxis {
            AxisMarks(values: dataList.map { $0.date.asString(withFormat: .monthDay) }) { value in
                if let dateString = value.as(String.self),
                   let date = dataList
                    .first(where: {
                        $0.date.asString(withFormat: .monthDay) == dateString
                    })?.date,
                   // 仮で月曜日のみラベルを表示
                   Calendar.current.component(.weekday, from: date) == 2 {
                    AxisValueLabel()
                        .font(.system(size: 16))
                        .foregroundStyle(.black)
                    AxisGridLine(
                        centered: true,
                        stroke: .init(lineWidth: 1, lineCap: .round, dash: [])
                    )
                        .foregroundStyle(.gray)
                }
            }
        }
        .background(.white)
    }
}

#Preview {
    DataChartView()
}
