def sharedPods 

  pod 'EasyMapping'
  pod 'SDWebImage', '~> 5.0.6'

  pod 'Mixpanel'

end

target 'Bitrise' do
  platform :osx, '10.12'
  pod "NSPopover+MISSINGBackgroundView"
  sharedPods()

  target 'BitriseTests' do
    inherit! :search_paths
  
    pod 'OCMock', '~> 3.4.3'
    pod 'Expecta', '~> 1.0.6'
    
  end

end

target 'BitriseATV' do
  platform :tvos, '14.0'
  sharedPods()
end