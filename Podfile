# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'

target 'Pocket3D' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Pocket3D
  pod "MJPEGStreamLib"
  pod "Starscream"
  pod 'IQKeyboardManagerSwift'
  pod 'NVActivityIndicatorView'

  target 'Pocket3DTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'Pocket3DUITests' do
    inherit! :search_paths
    # Pods for testing
  end
end

target 'OctoKit' do
  use_frameworks!

  pod 'Alamofire'
  pod 'SwiftyJSON'
end

pre_install do |installer|
  installer.analysis_result.specifications.each do |s|
    s.swift_version = '4.2' unless s.swift_version
  end
end
