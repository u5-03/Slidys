import importlib.util
from pathlib import Path
import unittest


spec = importlib.util.spec_from_file_location(
    'fix_video_player_spm', Path(__file__).resolve().parents[1] / 'fix_video_player_spm.py')
fix = importlib.util.module_from_spec(spec)
spec.loader.exec_module(fix)


class FixVideoPlayerTests(unittest.TestCase):
    def test_repairs_declaration_without_changing_conditional_target_reference(self):
        source = '''    .target(
      name: "objc",
      dependencies: [
        .target(name: "ios", condition: .when(platforms: [.iOS])),
      ]
    ),
    .target(
      name: "ios",
      cSettings: [.headerSearchPath("include")]
    ),
'''
        updated = fix.add_flutter_dependency(source, 'ios')
        self.assertIn('.target(name: "ios", condition: .when(platforms: [.iOS])),', updated)
        self.assertIn('name: "ios",\n      dependencies: [', updated)
        self.assertIn('cSettings: [.headerSearchPath("include")]', updated)
        self.assertEqual(updated.count('.product(name: "FlutterFramework"'), 1)

    def test_preserves_existing_dependencies(self):
        source = '''    .target(
      name: "objc",
      dependencies: [
        .target(name: "ios", condition: .when(platforms: [.iOS])),
      ]
    ),
'''
        updated = fix.add_flutter_dependency(source, 'objc')
        self.assertEqual(updated.count('dependencies: ['), 1)
        self.assertIn('.target(name: "ios", condition: .when(platforms: [.iOS])),', updated)
        self.assertEqual(updated.count('.product(name: "FlutterFramework"'), 1)


if __name__ == '__main__':
    unittest.main()
