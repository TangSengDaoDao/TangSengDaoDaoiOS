Pod::Spec.new do |s|
  s.name = 'WuKongIMSDK'
  s.version = '1.0.4'
  s.summary = '悟空IM是一款简单，高效，支持完全私有化的即时通讯.'
  s.license = {"type"=>"MIT", "file"=>"ios/LICENSE"}
  s.authors = {"tangtaoit"=>"tt@tgo.ai"}
  s.homepage = 'https://githubim.com'
  s.description = '悟空IM是一款简单，高效，支持完全私有化的即时通讯，提供群聊，点对点通讯解决方案'
  s.frameworks = ["UIKit", "MapKit","AVFoundation"]
  # s.libraries = ["opencore-amrnb", "opencore-amrwb", "vo-amrwbenc"]
  s.ios.libraries = ['c++','sqlite3','z']
  s.source = { :git => "https://github.com/WuKongIM/WuKongIMiOSSDK-Framework.git",:tag => "#{s.version}" }
  s.requires_arc = true
  s.ios.deployment_target    = '11.0'
  s.platform     = :ios, '11.0'
  s.resource             = 'ios/WuKongIMSDK.framework/WuKongIMSDK.bundle'
   s.vendored_frameworks  = 'ios/WuKongIMSDK.framework'
  s.xcconfig = {
    'OTHER_LDFLAGS' => '-ObjC',
    "LIBRARY_SEARCH_PATHS"=>"${PODS_ROOT}/../../WuKongIMiOSSDK-Framework/ios/lib",
   'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64',
    
  }
  s.dependency 'CocoaAsyncSocket', '~> 7.6.4'
  s.dependency 'FMDB/SQLCipher', '~>2.7.5'
  s.dependency '25519', '~>2.0.2'
end
