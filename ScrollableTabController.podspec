Pod::Spec.new do |s|
  s.name             = "ScrollableTabController"
  s.version          = "0.0.3"
  s.summary          = "ScrollableTabController"
  s.description      = "ScrollableTabController"
  s.homepage         = "https://github.com/speee/ScrollableTabController"
  s.license          = 'MIT'
  s.author           = { "Mitsuyoshi Yamazaki" => "yamazaki.mitsuyoshi@gmail.com" }
  s.source           = { :git => "https://github.com/speee/ScrollableTabController.git", :tag => "v#{s.version.to_s}" }

  s.requires_arc          = true
  s.ios.deployment_target = '10.0'

  s.source_files          = 'Source/*'
end
