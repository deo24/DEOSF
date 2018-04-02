#
#  Be sure to run `pod spec lint DEOSF.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = "DEOSF"
  s.version      = "0.0.5"
  s.summary      = "framework格式框架"
  s.homepage     = "https://github.com/deo24/DEOSF"
  

  s.license      = "MIT (example)"

  s.author       = { "deo24" => "email@address.com" }

  s.platform     = :ios, "8.0"

  s.source       = {:git => "https://github.com/deo24/DEOSF.git",:tag => "#{s.version}"}

  s.source_files  = "DEOSF/DEOSF/output/DEOSF.framework"

  s.requires_arc = true

end
