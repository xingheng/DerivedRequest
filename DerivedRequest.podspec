#
#  Be sure to run `pod spec lint DerivedRequest.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|
  s.name         = "DerivedRequest"
  s.version      = "0.1.0"
  s.summary      = "Series of derived classes for different servers' request and response."

  s.description  = <<-DESC
      DerivedRequest manages the network request session and response handler 
      in derived classes for different servers based on AFNetworking.
                   DESC

  s.homepage     = "https://github.com/xingheng/DerivedRequest"
  s.license      = "MIT"

  s.author             = { "Will Han" => "xingheng907@hotmail.com" }
  s.social_media_url   = "http://twitter.com/xingheng907"

  s.platform     = :ios, "8.0"
  s.source       = { :git => 'https://github.com/xingheng/DerivedRequest.git', :tag => s.version.to_s }

  s.source_files  = "Classes", "Classes/**/*.{h,m}"
  s.public_header_files = "Classes/**/*.h"

  s.requires_arc = true
  s.dependency "AFNetworking", "~> 3.0"

end
