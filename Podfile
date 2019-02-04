source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '10.3'
use_frameworks!

target 'Vocabulary' do
use_frameworks!
pod 'VSSocialButton'
pod 'TBEmptyDataSet'
pod 'Koloda'
pod 'AMPopTip'
pod 'Gallery'
pod 'Whisper'
pod 'Lightbox'
pod 'Hue'
pod 'ScrollableGraphView'
pod 'RealmSwift'
pod 'TJProfileImage'
pod 'M13ProgressSuite'
pod 'GLInAppPurchase'
pod 'Haptica'
pod 'Highlighter'
pod 'Former'
pod 'ESTabBarController-swift'
pod 'Branch'
pod 'MonkeyKing'
pod 'PieCharts'
pod 'Localize-Swift'
pod 'KVOController'
pod 'ElasticTransition'
pod 'Hero'
pod 'Pastel'
pod 'TKSubmitTransitionSwift3'
pod 'MIBlurPopup'
pod 'Bolts'
pod 'FBSDKCoreKit'
pod 'FBSDKShareKit'
pod 'FBSDKLoginKit'
pod 'LineSDK'
pod 'VK-ios-sdk'
pod 'SVProgressHUD'
pod 'arek'
pod 'Presentr'
pod 'PopupDialog'
pod 'SwiftCharts'
pod 'TinyConstraints'
pod 'EZAlertController'
pod 'OneSignal'
pod 'ChameleonFramework/Swift', :git => 'https://github.com/ViccAlexander/Chameleon.git'
pod 'PMSuperButton'
pod 'SwipeCellKit'
pod 'AZDialogView'
pod 'DGRunkeeperSwitch'
pod 'AEAccordion'
pod 'RealmContent'
pod 'Paralayout'

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.0'
    end
  end
end

end

