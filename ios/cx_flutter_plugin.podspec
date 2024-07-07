#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint cx_flutter_plugin.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'cx_flutter_plugin'
  s.version          = '0.0.1'
  s.summary          = 'Coralogix Flutter plugin.'
  s.description      = <<-DESC
Coralogix Flutter plugin.
                       DESC
  s.homepage         = 'http://www.coralogix.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Coralogix.com' => 'cx_ios@coralogix.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }


  s.dependency 'Coralogix', '~> 1.0.9'

  s.ios.deployment_target = '15.0'
  s.static_framework = true
end
