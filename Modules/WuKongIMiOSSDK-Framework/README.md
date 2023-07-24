
悟空IM 即时通讯的iOS SDK 详细使用请参考

https://githubim.com

pod spec lint --verbose --allow-warnings

pod trunk push WuKongIMSDK.podspec --allow-warnings


xcode14.3打包错误临时解决方案

Go to System Preferences → Security & Privacy → Full Disk Access → Terminal, and do:

cd /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/

sudo mkdir arc
cd  arc
sudo git clone https://github.com/kamyarelyasi/Libarclite-Files.git .

sudo chmod +x *

https://stackoverflow.com/questions/75574268/missing-file-libarclite-iphoneos-a-xcode-14-3/75729977#75729977


正式解决方案等CocoaPods官方（https://github.com/CocoaPods/CocoaPods/issues/11839）