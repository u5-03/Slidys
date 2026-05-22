//
//  DuelSharedStore.swift
//  YugiohDuelDiskPackage
//
//  パッケージ内で共有する DuelAppModel / DuelSessionStore の **明示的シングルトン** ホルダー。
//
//  SamplePages から開かれる Window と SlidysApp で起動される ImmersiveSpace は
//  別 Scene として独立しているため、同じインスタンスを参照させる必要がある。
//  EnvironmentKey の `defaultValue` 経由で「事実上のシングルトン」扱いをするのは
//  分かりづらいので、ここで明示的に static let で保持する。
//
//  外部から `.environment(\.duelAppModel, DuelSharedStore.appModel)` のように上書き注入することも可能。
//

import Foundation

public enum DuelSharedStore {
    public static let appModel = DuelAppModel()
    public static let session = DuelSessionStore()
}

/// ImmersiveSpace の ID 定数。Scene の `init` などで MainActor 隔離を踏まずに参照したいため
/// ここに切り出している(`DuelAppModel.immersiveSpaceID` と同じ値を保持)。
public enum DuelImmersiveSpaceID {
    public static let yugiohDuelDisk = "YugiohDuelDiskImmersiveSpace"
}
