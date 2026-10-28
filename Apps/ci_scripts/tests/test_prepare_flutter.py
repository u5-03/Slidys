"""Exercise the CI bootstrap in a fresh checkout without a real SDK or network."""
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


SCRIPTS = Path(__file__).resolve().parents[1]
FAKE_FLUTTER = '''#!/usr/bin/env python3
import json, os, pathlib, sys
args = sys.argv[1:]
with open(os.environ['CALL_LOG'], 'a') as log:
    log.write(json.dumps(args) + '\\n')
if args == ['--version', '--machine']:
    print(json.dumps({'frameworkVersion': os.environ.get('SDK_VERSION', '3.47.5')}))
elif args[:2] == ['pub', 'get']:
    pathlib.Path('.ios').mkdir(exist_ok=True)
    pathlib.Path('.ios/Podfile').write_text('generated legacy Podfile')
    pathlib.Path('.ios/Podfile.lock').write_text('generated lockfile')
    plugin = pathlib.Path.cwd() / 'plugin'
    manifest = plugin / 'darwin/video_player_avfoundation/Package.swift'
    if not os.environ.get('UNSUPPORTED_PLUGIN'):
        manifest.parent.mkdir(parents=True, exist_ok=True)
        manifest.write_text('// SwiftPM plugin')
    pathlib.Path('.flutter-plugins-dependencies').write_text(json.dumps({
        'plugins': {'ios': [{'name': 'video_player_avfoundation',
                            'path': str(plugin), 'native_build': True,
                            'shared_darwin_source': True}]}}))
elif args[:2] == ['build', 'swift-package']:
    assert not pathlib.Path('.ios/Podfile').exists()
    assert not pathlib.Path('.ios/Podfile.lock').exists()
'''


class PrepareFlutterTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix='slidys flutter ')
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.scripts = self.root / 'Apps/ci_scripts'
        self.scripts.mkdir(parents=True)
        shutil.copy(SCRIPTS / 'prepare_flutter.sh', self.scripts)
        shutil.copy(SCRIPTS / 'fix_video_player_spm.py', self.scripts)
        self.module = self.root / 'flutter_slide'
        self.sdk = self.module / '.fvm/flutter_sdk'
        (self.sdk / 'bin').mkdir(parents=True)
        (self.module / '.fvmrc').write_text(json.dumps({'flutter': '3.47.5'}))
        flutter = self.sdk / 'bin/flutter'
        flutter.write_text(FAKE_FLUTTER)
        flutter.chmod(0o755)
        self.env = dict(os.environ, CALL_LOG=str(self.root / 'calls.jsonl'))
        for key in ('FLUTTER_ROOT', 'CI_XCODEBUILD_ACTION', 'SDK_VERSION', 'UNSUPPORTED_PLUGIN'):
            self.env.pop(key, None)

    def run_prepare(self, **env):
        return subprocess.run([str(self.scripts / 'prepare_flutter.sh')], env=self.env | env,
                              capture_output=True, text=True)

    def calls(self):
        return [json.loads(line) for line in (self.root / 'calls.jsonl').read_text().splitlines()]

    def test_local_build_prepares_debug_and_release_without_pods(self):
        result = self.run_prepare()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.calls()[1:], [
            ['precache', '--ios'], ['pub', 'get', '--enforce-lockfile'],
            ['build', 'swift-package', '--platform', 'ios', '--build-mode', 'debug,release', '--no-codesign']])

    def test_cloud_archive_prepares_only_release(self):
        result = self.run_prepare(CI_XCODEBUILD_ACTION='archive')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.calls()[-1][-3:], ['--build-mode', 'release', '--no-codesign'])

    def test_project_ci_symlink_resolves_repository_root(self):
        project = self.root / 'Apps/SlidysFlutter'
        project.mkdir()
        (project / 'ci_scripts').symlink_to('../ci_scripts', target_is_directory=True)
        result = subprocess.run([str(project / 'ci_scripts/prepare_flutter.sh')],
                                env=self.env, capture_output=True, text=True)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.calls()[-1][:2], ['build', 'swift-package'])

    def test_unsupported_plugin_stops_before_build(self):
        result = self.run_prepare(UNSUPPORTED_PLUGIN='1')
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('iOS plugins must support SwiftPM: video_player_avfoundation', result.stderr)
        self.assertFalse(any(call[:2] == ['build', 'swift-package'] for call in self.calls()))

    def test_sdk_version_must_match_fvmrc(self):
        result = self.run_prepare(SDK_VERSION='3.44.0')
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('Flutter 3.47.5 is required', result.stderr)
        self.assertEqual(len(self.calls()), 1)

    def test_fresh_cloud_checkout_installs_pinned_sdk(self):
        fixture = self.root / 'fixture_flutter'
        shutil.copy(self.sdk / 'bin/flutter', fixture)
        shutil.rmtree(self.sdk)
        mock_bin = self.root / 'mock_bin'
        mock_bin.mkdir()
        git = mock_bin / 'git'
        git.write_text('''#!/usr/bin/env python3
import json, os, pathlib, shutil, sys
pathlib.Path(os.environ['GIT_LOG']).write_text(json.dumps(sys.argv[1:]))
sdk = pathlib.Path(sys.argv[-1])
(sdk / 'bin').mkdir(parents=True)
shutil.copy(os.environ['FIXTURE_FLUTTER'], sdk / 'bin/flutter')
''')
        git.chmod(0o755)
        result = self.run_prepare(PATH=str(mock_bin) + os.pathsep + self.env['PATH'],
                                  GIT_LOG=str(self.root / 'git.json'), FIXTURE_FLUTTER=str(fixture))
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(json.loads((self.root / 'git.json').read_text())[:-1],
                         ['clone', '--depth', '1', '--branch', '3.47.5', 'https://github.com/flutter/flutter.git'])

    def test_existing_screenshot_stub_does_not_skip_flutter_preparation(self):
        shutil.copy(SCRIPTS / 'ci_post_clone.sh', self.scripts)
        (self.scripts / 'prepare_flutter.sh').write_text('#!/bin/sh\nprintf prepared > "$MARKER"\n')
        checkout = self.root / 'checkout/repository'
        checkout.mkdir(parents=True)
        (checkout.parent / 'AppStoreScreenshotTest').mkdir()
        marker = self.root / 'prepared'
        result = subprocess.run([str(self.scripts / 'ci_post_clone.sh')], capture_output=True, text=True,
                                env=self.env | {'CI_PRIMARY_REPOSITORY_PATH': str(checkout), 'MARKER': str(marker)})
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(marker.read_text(), 'prepared')


if __name__ == '__main__':
    unittest.main()
