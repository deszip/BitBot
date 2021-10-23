def sharedPods 

  pod 'EasyMapping'
  pod 'Mixpanel'
  pod 'Sentry', :git => 'https://github.com/getsentry/sentry-cocoa.git', :tag => '7.1.0'

end

target 'BitBot' do
  platform :osx, '10.14'
  pod 'SDWebImage', '~> 5.0.6'
  
  sharedPods()
end

target 'BitBotTests' do
  inherit! :search_paths
  
  pod 'OCMock', '~> 3.4.3'
  pod 'Expecta', '~> 1.0.6'
  
end

target 'BitBotATV' do
  platform :tvos, '14.0'
  pod 'Kingfisher/SwiftUI'
  sharedPods()
end
