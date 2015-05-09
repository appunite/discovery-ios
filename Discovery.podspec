#
# Be sure to run `pod lib lint Discovery.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "Discovery"
  s.version          = "0.1.0"
  s.summary          = "Discover users around you using bluetooth."
  s.homepage         = "https://github.com/appunite/discovery-ios"
  s.license          = 'MIT'
  s.author           = { "Emil Wojtaszek" => "emil@appunite.com" }
  s.source           = { :git => "https://github.com/appunite/discovery-ios.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/**/*'
  
  s.frameworks = 'CoreBluetooth'
  s.dependency 'SocketRocket', '~> 0.2'
end
