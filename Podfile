def sharedPods 

  pod 'EasyMapping'

  pod 'Mixpanel'

end

target 'BitBot' do
  platform :osx, '10.12'
  pod "NSPopover+MISSINGBackgroundView"
  pod 'SDWebImage', '~> 5.0.6'
  sharedPods()

  target 'BitBotTests' do
    inherit! :search_paths
  
    pod 'OCMock', '~> 3.4.3'
    pod 'Expecta', '~> 1.0.6'
    
  end

end

target 'BitriseATV' do
  platform :tvos, '14.0'
  pod 'Kingfisher/SwiftUI'
  sharedPods()
end
