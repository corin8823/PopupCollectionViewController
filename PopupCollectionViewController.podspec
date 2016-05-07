Pod::Spec.new do |s|
  s.name             = "PopupCollectionViewController"
  s.version          = "0.0.1"
  s.summary          = "PopupCollectionViewController is a collectionView in Popup view"
  s.homepage         = "https://github.com/corin8823/PopupCollectionViewController"
  # s.screenshots      = "https://github.com/corin8823/PopupCollectionViewController/blob/master/ScreenShots/Screenshot.gif"
  s.license          = { :type => "MIT", :file => "LICENSE" }
  s.author           = { "corin8823" => "yusuke.t88@gmail.com" }
  s.source           = { :git => "https://github.com/corin8823/PopupCollectionViewController.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/corin8823'
  s.platform     = :ios, '8.0'
  s.requires_arc = true
  s.source_files = 'Pod/Classes/**/*'
end