//
//  UserDefaults.swift
//  Slidys
//
//  Created by Yugo Sugiyama on 2024/10/27.
//

import SwiftUI

public enum UserDefaultsKey: String {
    case strokeUnitMilliseconds
    case soundScaleUnit
    case selectedThemeColor
    case shouldShowSoundKey
    case defaultStrokeVelocity
}

public extension UserDefaults {
    var strokeUnitMilliseconds: Int {
        get {
            let value = UserDefaults.standard.integer(forKey: UserDefaultsKey.strokeUnitMilliseconds.rawValue)
            return value == 0 ? 20 : value
        }
        set {
            UserDefaults.standard.setValue(max(1, min(1000, newValue)), forKey: UserDefaultsKey.strokeUnitMilliseconds.rawValue)
        }
    }

    var selectedThemeColor: Color {
        get {
            guard let colorString = UserDefaults.standard.string(forKey: UserDefaultsKey.selectedThemeColor.rawValue) else { return .orange }
            return Color(rawValue: colorString) ?? Color.orange
        }
        set {
            UserDefaults.standard.setValue(newValue.rawValue, forKey: UserDefaultsKey.selectedThemeColor.rawValue)
        }
    }

    var defaultStrokeVelocity: Int {
        get {
            let defaultStrokeVelocity = UserDefaults.standard.integer(forKey: UserDefaultsKey.defaultStrokeVelocity.rawValue)
            return defaultStrokeVelocity == 0 ? PianoConstants.defaultVelocity : defaultStrokeVelocity
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: UserDefaultsKey.defaultStrokeVelocity.rawValue)
        }
    }

    var keyDisplayType: KeyDisplayType {
        get {
            let KeyDisplayTypeString = UserDefaults.standard.string(forKey:  UserDefaultsKey.soundScaleUnit.rawValue) ?? ""
            return KeyDisplayType(rawValue: KeyDisplayTypeString) ?? .default
        }
        set {
            UserDefaults.standard.setValue(newValue.rawValue, forKey: UserDefaultsKey.soundScaleUnit.rawValue)
        }
    }

    var shouldShowSoundKey: Bool {
        get {
            return UserDefaults.standard.bool(forKey: UserDefaultsKey.shouldShowSoundKey.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultsKey.shouldShowSoundKey.rawValue)
        }
    }
}



