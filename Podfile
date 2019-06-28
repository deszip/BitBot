 platform :osx, '10.12'

target 'Bitrise' do
  # use_frameworks!

  pod 'EasyMapping'
  pod 'SDWebImage', :podspec => 'https://raw.githubusercontent.com/SDWebImage/SDWebImage/master/SDWebImage.podspec'
  pod 'Mixpanel-OSX-Community', :git => 'https://github.com/orta/mixpanel-osx-unofficial.git'

  target 'BitriseTests' do
    inherit! :search_paths
  
    pod 'OCMock', '~> 3.4.3'
    pod 'Expecta', '~> 1.0.6'
    
  end

end
