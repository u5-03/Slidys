#!/usr/bin/env ruby
# Adds SlidysShareScreenshots target to SlidysShare.xcodeproj
# Usage: ruby Scripts/add_screenshot_target.rb

$LOAD_PATH.unshift(*Dir.glob(File.expand_path("~/.gem/ruby/*/gems/*/lib")))
require 'xcodeproj'

project_path = File.join(__dir__, '..', 'SlidysShare.xcodeproj')
project = Xcodeproj::Project.open(project_path)

# Check if target already exists
if project.targets.any? { |t| t.name == 'SlidysShareScreenshots' }
  puts "Target 'SlidysShareScreenshots' already exists. Skipping."
  exit 0
end

# Get reference target for build settings
main_target = project.targets.find { |t| t.name == 'SlidysShare' }
abort("Could not find SlidysShare target") unless main_target

# Create new application target
screenshot_target = project.new_target(
  :application,
  'SlidysShareScreenshots',
  :ios,
  '26.0'
)
screenshot_target.build_configurations.each do |config|
  main_config = main_target.build_configurations.find { |c| c.name == config.name }
  next unless main_config

  config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = 'yugo.sugiyama.SlidysShare.Screenshots'
  config.build_settings['INFOPLIST_FILE'] = 'SlidysShareScreenshots/Info.plist'
  config.build_settings['GENERATE_INFOPLIST_FILE'] = 'NO'
  config.build_settings['SWIFT_VERSION'] = main_config.build_settings['SWIFT_VERSION'] || '6.0'
  config.build_settings['SUPPORTED_PLATFORMS'] = 'iphoneos iphonesimulator macosx xros xrsimulator'
  config.build_settings['SUPPORTS_MACCATALYST'] = 'NO'
  config.build_settings['TARGETED_DEVICE_FAMILY'] = '1,2,7'
  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '26.0'
  config.build_settings['MACOSX_DEPLOYMENT_TARGET'] = '26.0'
  config.build_settings['XROS_DEPLOYMENT_TARGET'] = '26.0'
  config.build_settings['SUPPORTS_XR_DESIGNED_FOR_IPHONE_IPAD'] = 'NO'
  config.build_settings['CODE_SIGN_STYLE'] = 'Automatic'
  config.build_settings['DEVELOPMENT_TEAM'] = main_config.build_settings['DEVELOPMENT_TEAM']
  config.build_settings['PRODUCT_NAME'] = '$(TARGET_NAME)'
  config.build_settings['ASSETCATALOG_COMPILER_APPICON_NAME'] = 'AppIcon'
  config.build_settings['SWIFT_STRICT_CONCURRENCY'] = 'complete'
  config.build_settings['SWIFT_EMIT_LOC_STRINGS'] = 'YES'
  # Multi-platform: need to support all three
  config.build_settings['SDKROOT'] = 'auto'
end

# --- Add screenshot source files ---
screenshots_group = project.main_group.new_group('SlidysShareScreenshots', 'SlidysShareScreenshots')

screenshot_source_files = %w[
  ScreenshotApp.swift
  ScreenshotContentViews.swift
  ScreenshotSampleData.swift
  FakeSlideConnection.swift
]

screenshot_source_files.each do |filename|
  file_ref = screenshots_group.new_file(filename)
  screenshot_target.source_build_phase.add_file_reference(file_ref)
end

# Add Info.plist (not compiled, just referenced)
screenshots_group.new_file('Info.plist')

# Add JSON to bundle resources
json_ref = screenshots_group.new_file('slidys-share-screenshots.json')
screenshot_target.resources_build_phase.add_file_reference(json_ref)

# --- Add production view files as compile sources (shared with main target) ---
def find_file_ref(group, name)
  group.recursive_children.find { |c| c.respond_to?(:path) && c.path == name }
end

production_files = %w[
  SlideBroadcastView.swift
  SlideReceiverView.swift
  SlideEditView.swift
  SlideListView.swift
  SlideDetailView.swift
  SlidePreviewView.swift
  ReactionOverlayView.swift
  ReactionPickerView.swift
  SettingsView.swift
  DonationView.swift
  MultipeerManager.swift
  SlideStorage.swift
  MarkdownSlideParser.swift
  SlideDeck+Markdown.swift
  LocalizedExtensions.swift
  PreviewHelpers.swift
  ContentView.swift
]

production_files.each do |filename|
  ref = find_file_ref(project.main_group, filename)
  if ref
    screenshot_target.source_build_phase.add_file_reference(ref)
    puts "  Added #{filename} to screenshot target"
  else
    puts "  WARNING: Could not find #{filename}"
  end
end

# --- Add package product dependencies ---
# Find existing package references from main target
main_target.package_product_dependencies.each do |dep|
  puts "  Main target has package dependency: #{dep.product_name}"
end

# We need: SlidysShareCore, SlideKit (already in project as packages)
# And: AppStoreScreenshotTestCore (new local package)

# Add local package reference for AppStoreScreenshotTest
appstore_screenshot_path = '../../../AppStoreScreenshotTest'
# Check if already added
existing_pkg = project.root_object.package_references&.find { |p|
  p.respond_to?(:relative_path) && p.relative_path == appstore_screenshot_path
}

unless existing_pkg
  # Add local package reference
  pkg_ref = project.root_object.package_references || []
  local_pkg = project.new(Xcodeproj::Project::Object::XCLocalSwiftPackageReference)
  local_pkg.relative_path = appstore_screenshot_path
  project.root_object.package_references = (project.root_object.package_references || []) + [local_pkg]
  puts "  Added local package reference: #{appstore_screenshot_path}"
  existing_pkg = local_pkg
end

# Add package product dependencies to screenshot target
%w[AppStoreScreenshotTestCore].each do |product_name|
  dep = project.new(Xcodeproj::Project::Object::XCSwiftPackageProductDependency)
  dep.product_name = product_name
  dep.package = existing_pkg
  screenshot_target.package_product_dependencies << dep

  # Also add to frameworks build phase
  build_file = project.new(Xcodeproj::Project::Object::PBXBuildFile)
  build_file.product_ref = dep
  screenshot_target.frameworks_build_phase.files << build_file
  puts "  Added package dependency: #{product_name}"
end

# Add existing packages (SlidysShareCore, SlideKit) to screenshot target
main_target.package_product_dependencies.each do |dep|
  next unless %w[SlidysShareCore SlideKit].include?(dep.product_name)

  new_dep = project.new(Xcodeproj::Project::Object::XCSwiftPackageProductDependency)
  new_dep.product_name = dep.product_name
  new_dep.package = dep.package
  screenshot_target.package_product_dependencies << new_dep

  build_file = project.new(Xcodeproj::Project::Object::PBXBuildFile)
  build_file.product_ref = new_dep
  screenshot_target.frameworks_build_phase.files << build_file
  puts "  Added package dependency: #{dep.product_name}"
end

# Add Localizable.xcstrings and InfoPlist.xcstrings to resources if they exist
%w[Localizable.xcstrings InfoPlist.xcstrings].each do |filename|
  ref = find_file_ref(project.main_group, filename)
  if ref
    screenshot_target.resources_build_phase.add_file_reference(ref)
    puts "  Added #{filename} to resources"
  end
end

# Add Assets.xcassets to resources
assets_ref = find_file_ref(project.main_group, 'Assets.xcassets')
if assets_ref
  screenshot_target.resources_build_phase.add_file_reference(assets_ref)
  puts "  Added Assets.xcassets to resources"
end

# Add StoreKit config if found
storekit_ref = find_file_ref(project.main_group, 'Products.storekit')
if storekit_ref
  screenshot_target.resources_build_phase.add_file_reference(storekit_ref)
  puts "  Added Products.storekit to resources"
end

project.save
puts "\nDone! Target 'SlidysShareScreenshots' added to #{project_path}"
