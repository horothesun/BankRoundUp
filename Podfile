# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'BankRoundUp' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for BankRoundUp
  pod 'RxSwift',     '~> 4.2'
  pod 'RxCocoa',     '~> 4.2'
  pod 'Alamofire',   '~> 4.7'
  pod 'RxAlamofire', '~> 4.2'

  target 'BankRoundUpTests' do
    inherit! :search_paths
    # Pods for testing
    pod 'Nimble',     '~> 7.1'
    pod 'Quick',      '~> 1.3'
    pod 'RxBlocking', '~> 4.2'
    pod 'RxTest',     '~> 4.2'
  end

end

# Workaround for Cocoapods issue #7606
post_install do |installer|
  installer.pods_project.build_configurations.each do |config|
      config.build_settings.delete('CODE_SIGNING_ALLOWED')
      config.build_settings.delete('CODE_SIGNING_REQUIRED')
  end
end
