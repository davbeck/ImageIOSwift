Pod::Spec.new do |s|
  s.name             = 'ImageIOSwiftUI'
  s.version          = '1.2.0'
  s.summary          = 'UIKit integration for ImageIO.'

  s.description      = <<-DESC
  ImageIO is an Apple framework that provides low level access to image files and is what powers UIImage and other image related operations on iOS and macOS. However, in part because it is a C/Core Foundation framework, using it can be difficult.

  ImageIO.Swift is a lightweight wrapper around the framework that makes it much easier to access the vast power that ImageIO provides, including animated GIFs, incremental loading and efficient thumbnail generation.

  While there are alternatives that provide many of the same features, and many of them use very similar implimentations based on `ImageIO`, this project provides a unified interface for all uses of ImageIO. So for instance you can use the same view and image processing code for animated images, progressive jpegs, and any other format that ImageIO supports.
                       DESC

  s.homepage         = 'https://github.com/davbeck/ImageIOSwift'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'davbeck' => 'code@davidbeck.co' }
  s.source           = { :git => 'https://github.com/davbeck/ImageIOSwift.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/davbeck'

  s.swift_version = '5.1'
  s.ios.deployment_target = '13.0'
  s.osx.deployment_target = '10.15'
  s.tvos.deployment_target = '13.0'
  s.watchos.deployment_target = '6.0'
  s.static_framework = true

  s.source_files = 'Sources/ImageIOSwiftUI/*.swift'

  s.frameworks = 'SwiftUI', 'Combine'
	
  s.dependency 'ImageIOSwift', s.version.to_s
end
