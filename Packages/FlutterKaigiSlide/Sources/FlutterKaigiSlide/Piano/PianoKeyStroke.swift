//
//  PianoKeyStroke.swift
//  Slidys
//
//  Created by Yugo Sugiyama on 2024/10/27.
//

import Foundation
import CoreMIDI
import CoreAudio

public struct PianoKeyStroke: Equatable, Identifiable, Hashable, Codable {
    public let key: PianoKey
    public let velocity: Int
    public let timestampNanoSecond: UInt64
    public let isOn: Bool
    public var velocityPercent: Int {
        let percent = Int(Double(velocity) / Double(PianoKeyStroke.maxVelocity) * Double(100))
        return min(max(percent, 0), 100)
    }
    public var velocityRatio: Double {
        let percent = Int(Double(velocity) / Double(PianoKeyStroke.maxVelocity) * Double(100))
        return Double(min(max(percent, 0), 100)) / 100
    }
    public var noteNumber: Int {
        return key.noteNumber
    }
    public var keyStrokedType: KeyStrokedType {
        return isOn ? .stroked(percent: velocityPercent) : .unstroked
    }

    public static let maxVelocity = 127
    public static let minVelocity = 0

    public static var random: PianoKeyStroke {
        return PianoKeyStroke(key: .random(octave: .fourth), velocity: Int.random(in: PianoKeyStroke.minVelocity...PianoKeyStroke.maxVelocity), timestampNanoSecond: .now, isOn: true)
    }

    public var id: String {
        return key.id + isOn.description + timestampNanoSecond.description
    }

    public var miliSecondInterval: TimeInterval {
        return TimeInterval(timestampNanoSecond) / TimeInterval(NSEC_PER_MSEC)
    }

    public var secondInterval: TimeInterval {
        return TimeInterval(timestampNanoSecond) / TimeInterval(NSEC_PER_SEC)
    }

    public var asStrokeOff: PianoKeyStroke {
        return PianoKeyStroke(key: key, velocity: velocity, timestampNanoSecond: timestampNanoSecond, isOn: false)
    }

    public var asKeyStrokedType: KeyStrokedType {
        return isOn ? .stroked(percent: velocityPercent) : .unstroked
    }

    public init(key: PianoKey, velocity: Int, timestampNanoSecond: MIDITimeStamp, isOn: Bool = true) {
        self.key = key
        self.velocity = velocity
        self.timestampNanoSecond = timestampNanoSecond
        self.isOn = isOn
    }
}

extension Array where Element == PianoKeyStroke {
    public var onlyStrokedKeyStroke: [PianoKeyStroke] {
        var pianoKeyStroke: [PianoKeyStroke] = []
        forEach { keyStroke in
            if pianoKeyStroke.contains(
                where: { $0.noteNumber == keyStroke.noteNumber && $0.isOn }
            ) {
                pianoKeyStroke.removeAll(where: { $0.noteNumber == keyStroke.noteNumber })
            } else {
                pianoKeyStroke.append(keyStroke)
            }
        }
        return pianoKeyStroke
    }
}

extension Array: Identifiable where Element == PianoKeyStroke {
    public var id: String {
        return reduce("") { initialValue, value in
            return initialValue + value.id
        }
    }
}

public extension UInt64 {
    static var now: UInt64 {
        // Get current host DateTime
        let machTime = mach_absolute_time()

        // Get host time frequency information
        var timebaseInfo = mach_timebase_info_data_t()
        mach_timebase_info(&timebaseInfo)

        // Convert host time to nanoseconds
        let nanoSeconds = machTime * UInt64(timebaseInfo.numer) / UInt64(timebaseInfo.denom)

        return nanoSeconds
    }
}

