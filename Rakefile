PROJECT = 'HatenaBookmarkSDKTests/HatenaBookmarkSDKTests.xcodeproj'
DEMO_PROJECT = 'DemoAppForAutomation/DemoApp.xcodeproj'
TARGET = 'HatenaBookmarkSDKTests'
DEMO_TARGET = 'DemoAppForAutomation'
DEMO_DIR = 'DemoAppForAutomation'
TMP_DIR = 'tmp'
JAVASCRIPT_DIR = 'DemoAppForAutomation/specs/javascript'

desc 'Clean up and run all tests.'
task :default => [:clean, :test]

desc 'Run unit tests and UIAutomation tests.'
task :test => [:unittest, :uitest]

desc 'Build HTBHatenaBookmarkSDKTests and run unit tests.'
task :unittest do
  sh "xcodebuild -project #{PROJECT} -target #{TARGET} -sdk iphonesimulator TEST_AFTER_BUILD=YES ONLY_ACTIVE_ARCH=NO TEST_HOST="
end

desc 'Clean build folder via xcodebuild'
task :clean do
  sh "xcodebuild -project #{PROJECT} clean"
end

desc 'Build demo application for testing.'
task :build do
  tmp_path = [Dir.pwd, TMP_DIR].join(File::SEPARATOR)
  directory tmp_path
  sh "xcodebuild -project #{DEMO_PROJECT} -target #{DEMO_TARGET} -configuration Automation -sdk iphonesimulator6.1 ONLY_ACTIVE_ARCH=NO CONFIGURATION_BUILD_DIR=#{tmp_path} TARGETED_DEVICE_FAMILY=1"
end

desc 'Build demo application and run automation.'
task :uitest => [:build, :automation]

desc 'Run UIAutomation tests.'
task :automation
task :automation, "files"
task :automation do |t, args|
  files = args[:files].nil? ? [] : args[:files].split()
  tmp_path = [Dir.pwd, TMP_DIR].join(File::SEPARATOR)
  app_path = [tmp_path, "#{DEMO_TARGET}.app"].join(File::SEPARATOR)
  Rake::Task[:build].execute unless File.exists? app_path 
  Rake::Task[:clean_logs].execute

  if files.empty?
    js_files = FileList["#{JAVASCRIPT_DIR}/*.js"]
  else
    js_files = FileList[]
    files.each do |filename|
      js_files.include "#{JAVASCRIPT_DIR}/#{filename}.js"
    end
  end
  js_files.each do |path|
    sh "DemoAppForAutomation/tuneup_js/test_runner/run #{app_path} #{path} #{tmp_path} -c -x"
    Rake::Task[:clean_logs].execute
  end
end

desc 'Validate Podspec and .travis.yml'
task :lint do
  sh 'pod lib lint'
  sh 'travis-lint'
end

desc 'Remove log files made by running automation test'
task :clean_logs do
  tmp_path = [Dir.pwd, TMP_DIR].join(File::SEPARATOR)
  app_path = [tmp_path, "#{DEMO_TARGET}.app"].join(File::SEPARATOR)
  logs = FileList["#{tmp_path}/*"]
  logs.exclude(app_path)
  logs.each do |path|
    sh "rm -rf '#{path}'"
  end
end
