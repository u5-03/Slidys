"""Repair missing Flutter dependencies in the generated video_player package.

video_player_avfoundation 2.12.0 (also 2.12.3) declares FlutterFramework on
its Swift target, but not on the Objective-C targets that import Flutter.
Flutter's generator sees the package-level dependency and skips injection.
Only the generated copy is changed; the pub cache and SDK remain untouched.
"""
import json
from pathlib import Path
import re
import subprocess
import sys


def add_flutter_dependency(source, target_name):
    # Match target declarations, never inline .target(name: ...) references.
    # SwiftPM's add-target-dependency command also matches those references.
    pattern = re.compile(
        r'(^[ \t]*\.target\(\s*\n(?P<indent>[ \t]*)name:\s*"'
        + re.escape(target_name) + r'",[ \t]*\n)'
        r'(?P<dependencies>[ \t]*dependencies:\s*\[)?', re.MULTILINE)

    def replace(match):
        indent = match['indent']
        dependency = '.product(name: "FlutterFramework", package: "FlutterFramework"),'
        if match['dependencies']:
            return match[0] + '\n' + indent + '  ' + dependency
        return (match[1] + indent + 'dependencies: [\n' + indent + '  ' + dependency
                + '\n' + indent + '],\n')

    updated, count = pattern.subn(replace, source)
    if count != 1:
        raise SystemExit(f'error: Cannot repair SwiftPM target {target_name}; review its Package.swift')
    return updated


def fix_package(output):
    package = (output / 'FlutterNativeIntegration/.plugins/video_player_avfoundation'
               / 'darwin/video_player_avfoundation')
    if not (package / 'Package.swift').is_file():
        return  # This project may no longer depend on video_player.

    swift = ['xcrun', '--sdk', 'macosx', 'swift', 'package', '--package-path', str(package)]
    manifest = json.loads(subprocess.check_output(swift + ['dump-package'], text=True))
    package_file = package / 'Package.swift'
    original = package_file.read_text()
    source = original
    for target in manifest['targets']:
        if target['type'] != 'regular':
            continue
        if any(dependency.get('product', [None])[0] == 'FlutterFramework'
               for dependency in target['dependencies']):
            continue
        print(f"Adding FlutterFramework dependency to {target['name']}", flush=True)
        source = add_flutter_dependency(source, target['name'])
    if source != original:
        package_file.write_text(source)
        subprocess.run(swift + ['dump-package'], check=True, stdout=subprocess.DEVNULL)


if __name__ == '__main__':
    fix_package(Path(sys.argv[1]).resolve())
