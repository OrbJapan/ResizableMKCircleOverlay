Pod::Spec.new do |s|
  s.name         = "ResizableMKCircleOverlay"
  s.version      = "0.0.1"
  s.summary      = "A resizable map circle overlay."
  s.homepage     = "http://github.com/OrbJapan/ResizableMKCircleOverlay"
  s.screenshot   = "https://github.com/OrbJapan/ResizableMKCircleOverlay/blob/master/screenshots/IMG_0002.PNG"
  s.license      = { :type => 'Apache', :file => 'LICENSE' }
  s.author       = { "OrbJapan" => "" }
  s.source       = { :git => "https://github.com/OrbJapan/ResizableMKCircleOverlay.git", :tag => s.version.to_s }
  s.platform     = :ios
  s.source_files = 'classes/*.{h,m}'
  s.frameworks   = 'CoreLocation', 'Foundation', 'MapKit', 'QuartzCore', 'UIKit'
  s.requires_arc = true
end
