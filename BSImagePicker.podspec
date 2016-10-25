Pod::Spec.new do |s|
  s.name             = "BSImagePicker"
  s.version          = "2.4.0-leyefe"
  s.summary          = "BSImagePicker is a multiple image picker for iOS. UIImagePickerController replacement"
  s.description      = <<-DESC
  A mix between the native iOS gallery and facebooks image picker. Allows you to preview and select multiple images.
  It is intended as a replacement for UIImagePickerController for both selecting and taking photos.
                       DESC
  s.homepage         = "https://github.com/rbrovko/BSImagePicker"
  s.license          = 'MIT'
  s.author           = { "Joakim Gyllström" => "joakim@backslashed.se" }
  s.source           = { :git => "https://github.com/rbrovko/BSImagePicker.git", :tag => s.version }

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'BSImagePicker' => ['Pod/Assets/*.png',
                        'Pod/Assets/*.xib',
                        'Pod/Assets/*.storyboard',
                        'Pod/Assets/*.xcassets',
                        'Pod/Assets/*.png']
  }

  s.frameworks = 'UIKit', 'Photos'
  s.dependency 'UIImageViewModeScaleAspect', '~> 1.3'
  s.dependency 'BSGridCollectionViewLayout', '1.2.0-swift23-leyefe’, :git => "https://github.com/rbrovko/BSGridCollectionViewLayout.git"
end
