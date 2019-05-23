#
# Be sure to run `pod lib lint akupriia2019.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'akupriia2019'
  s.version          = '0.1.0'
  s.summary          = 'This pod allows you to add articles and manage them.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = 'A small pod to manage articles. Created for d08 of Swift iOS Pool.'

  s.homepage         = 'https://github.com/ArtemisKS/akupriia2019.git'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ArtemisKS' => 'Artemkupriyanets@yahoo.com' }
  s.source           = { :git => 'https://github.com/ArtemisKS/akupriia2019.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'
  s.swift_version = '4.0'

  s.source_files = 'akupriia2019/Classes/**/*.{h,m,swift,xcdatamodeld}'
  s.resources = 'akupriia2019/Classes/**/*.{xcdatamodeld}'
  
  # s.resource_bundles = {
  #   'akupriia2019' => ['akupriia2019/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit', 'MapKit', 'CoreData'
  # s.dependency 'AFNetworking', '~> 2.3'

end
