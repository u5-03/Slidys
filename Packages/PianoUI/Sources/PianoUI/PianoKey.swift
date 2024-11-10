//
//  PianoKey.swift
//  Slidys
//
//  Created by Yugo Sugiyama on 2024/10/27.
//

import Foundation

public struct PianoKey: Equatable, Identifiable, Hashable, Codable {
    public let keyType: KeyType
    public let octave: Octave

    public var id: String {
        return keyType.id.description + octave.id.description
    }

    public var noteNumber: Int {
        return octave.octaveNumber * KeyType.allCases.count + keyType.keyIndex
    }

    public var isC: Bool {
        return keyType == .c
    }

    public var isBlackKey: Bool {
        return keyType.isBlackKey
    }

    public var isWhiteKey: Bool {
        return !keyType.isBlackKey
    }

    public func keyDisplayValue(keyDisplayType: KeyDisplayType) -> String {
        let keyString = switch keyDisplayType {
        case .english: keyType.keyEnglishName
        case .germany: keyType.keyGermanyName
        case .italic: keyType.keyItalicName
        case .italicKatakana: keyType.keyItalicKatakanaName
        case .japanese: keyType.keyJapaneseName
        }
        return octave.octaveNumber.description + keyString
    }

    public static var random: PianoKey {
        return PianoKey(keyType: .random, octave: .random)
    }

    public init(keyType: KeyType, octave: Octave) {
        self.keyType = keyType
        self.octave = octave
    }

    public init(noteNumber: Int) {
        let numberOfKeys = KeyType.allCases.count
        let octaveIndex = noteNumber / numberOfKeys
        let keyIndex = noteNumber % numberOfKeys

        guard let keyType = KeyType(rawValue: keyIndex),
              let octave = Octave(rawValue: octaveIndex) else {
            fatalError("\(noteNumber) is invalid note number(Octave: \(octaveIndex), keyIndex: \(keyIndex)")
        }

        self.keyType = keyType
        self.octave = octave
    }

    public static var allCases: [PianoKey] {
        Octave.allCases.map { octave in
            return KeyType.allCases.map { keyType in
                return PianoKey(keyType: keyType, octave: octave)
            }
        }
        .flatMap({ $0 })
    }

    public static func random(octave: Octave) -> PianoKey {
        return PianoKey(keyType: .random, octave: octave)
    }
}

public enum Octave: Int, CaseIterable, Identifiable, Codable {
    case minusFirst
    case zero
    case first
    case second
    case third
    case fourth
    case fifth
    case sixth
    case seventh
    case eighth
    case ninth

    public static var random: Octave {
        return Octave.allCases.randomElement() ?? .zero
    }

    public var id: Int {
        return octaveNumber
    }

    public var index: Int {
        return rawValue
    }

    public var octaveNumber: Int {
        return rawValue - 1
    }
}

public enum KeyDisplayType: String, CaseIterable, Identifiable, Codable, Sendable {
    public var id: String {
        return rawValue
    }

    case english
    case germany
    case italic
    case italicKatakana
    case japanese

    public static let `default` = KeyDisplayType.english

    public var displayName: String {
        switch (self) {
        case .english: return "英語"
        case .germany: return "ドイツ"
        case .italic: return "イタリア"
        case .italicKatakana: return "イタリア(カタカナ)"
        case .japanese: return "日本"
        }
    }
}

public enum KeyType: Int, CaseIterable, Identifiable, Codable {
    case c
    case cSharp
    case d
    case dSharp
    case e
    case f
    case fSharp
    case g
    case gSharp
    case a
    case aSharp
    case b

    public static var random: KeyType {
        return KeyType.allCases.randomElement() ?? .c
    }

    public var id: Int {
        return keyIndex
    }

    public var isNextBlackKeyEmpty: Bool {
        switch self {
        case .dSharp, .aSharp:
            return true
        default:
            return false
        }
    }

    public var keyTypePairs: [[KeyType]] {
        return [
            [.c, .cSharp],
            [.d, .dSharp],
            [.e],
            [.f, .fSharp],
            [.g, .gSharp],
            [.a, .aSharp],
            [.b]
        ]
    }

    public var keyIndex: Int {
        return rawValue
    }

    public var isWhiteKeyIndex: Int {
        switch self {
        case .c: return 0
        case .d: return 1
        case .e: return 2
        case .f: return 3
        case .g: return 4
        case .a: return 5
        case .b: return 6
        default: return -1
        }
    }

    public var keyOffsetRatio: CGFloat {
        let defaultOffset = 0.12
        switch self {
        case .cSharp: return -defaultOffset
        case .dSharp: return defaultOffset
        case .fSharp: return -defaultOffset
        case .gSharp: return 0
        case .aSharp: return defaultOffset
        default: return 0
        }
    }

    public var isBlackKey: Bool {
        switch self {
        case .cSharp, .dSharp, .fSharp, .gSharp, .aSharp:
            return true
        case .c, .d, .e, .f, .g, .a, .b:
            return false
        }
    }

    public var isWhiteKey: Bool {
        return !isBlackKey
    }

    public var keyEnglishName: String {
        switch self {
        case .c:
            return "C"
        case .cSharp:
            return "C#"
        case .d:
            return "D"
        case .dSharp:
            return "D#"
        case .e:
            return "E"
        case .f:
            return "F"
        case .fSharp:
            return "F#"
        case .g:
            return "G"
        case .gSharp:
            return "G#"
        case .a:
            return "A"
        case .aSharp:
            return "A#"
        case .b:
            return "B"
        }
    }

    public var keyGermanyName: String {
        switch self {
        case .c:
            return "C"
        case .cSharp:
            return "Cis"
        case .d:
            return "D"
        case .dSharp:
            return "Dis"
        case .e:
            return "E"
        case .f:
            return "F"
        case .fSharp:
            return "Fis"
        case .g:
            return "G"
        case .gSharp:
            return "Gis"
        case .a:
            return "A"
        case .aSharp:
            return "Ais"
        case .b:
            return "H"
        }
    }

    public var keyItalicName: String {
        switch self {
        case .c:
            return "Do"
        case .cSharp:
            return "Do♯"
        case .d:
            return "Re"
        case .dSharp:
            return "Re♯"
        case .e:
            return "Mi"
        case .f:
            return "Fa"
        case .fSharp:
            return "Fa♯"
        case .g:
            return "Sol"
        case .gSharp:
            return "Sol♯"
        case .a:
            return "La"
        case .aSharp:
            return "La♯"
        case .b:
            return "Si"
        }
    }

    public var keyItalicKatakanaName: String {
        switch self {
        case .c:
            return "ド"
        case .cSharp:
            return "ド♯"
        case .d:
            return "レ"
        case .dSharp:
            return "レ♯"
        case .e:
            return "ミ"
        case .f:
            return "ファ"
        case .fSharp:
            return "ファ♯"
        case .g:
            return "ソ"
        case .gSharp:
            return "ソ♯"
        case .a:
            return "ラ"
        case .aSharp:
            return "ラ♯"
        case .b:
            return "シ"
        }
    }

    public var keyJapaneseName: String {
        switch self {
        case .c:
            return "ハ"
        case .cSharp:
            return "嬰ハ"
        case .d:
            return "ニ"
        case .dSharp:
            return "嬰ニ"
        case .e:
            return "ホ"
        case .f:
            return "ヘ"
        case .fSharp:
            return "嬰ヘ"
        case .g:
            return "ト"
        case .gSharp:
            return "嬰ト"
        case .a:
            return "イ"
        case .aSharp:
            return "嬰イ"
        case .b:
            return "ロ"
        }
    }
}

