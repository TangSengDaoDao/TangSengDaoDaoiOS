# 环境变量
#version=$MajorVersion"."$MinorVersion"."$FixVersion"."$BuildNo
#shortVersion=$MajorVersion"."$MinorVersion"."$FixVersion
version=1.0.0
shortVersion=1.0.0

xcworkspace="WuKongIMSDK"
scheme="WuKongIMSDK"
configuration="Release"

WORKSPACE=`pwd`
RESULT_DIR=$WORKSPACE/out

# 清理工作区
rm -r ~/Library/Developer/Xcode/Archives/`date +%Y-%m-%d`/$scheme\ *.xcarchive
xcodebuild clean -workspace $xcworkspace.xcworkspace -scheme $scheme -configuration $configuration

# 更新版本号
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $version" $scheme/$scheme/Info.plist
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $shortVersion" $scheme/$scheme/Info.plist

# 分别编译真机和模拟器的 framework
xcodebuild -workspace $xcworkspace.xcworkspace -scheme $scheme -configuration $configuration ONLY_ACTIVE_ARCH=NO -sdk iphoneos BUILD_DIR="$RESULT_DIR" BUILD_ROOT="${BUILD_ROOT}" clean build
if ! [ $? = 0 ] ;then
    echo "xcodebuild iphoneos fail"
    exit 1
fi

xcodebuild -workspace $xcworkspace.xcworkspace -scheme $scheme -configuration $configuration ONLY_ACTIVE_ARCH=NO -sdk iphonesimulator BUILD_DIR="$RESULT_DIR" BUILD_ROOT="${BUILD_ROOT}" clean build
if ! [ $? = 0 ] ;then
    echo "xcodebuild iphonesimulator fail"
    exit 1
fi

# 合并 framework，输出适用真机和模拟器的 framework 到 result 目录
cp -R "$RESULT_DIR/${configuration}-iphoneos/${scheme}/${scheme}.framework/"  "$RESULT_DIR/${scheme}_${version}.framework/" 
lipo -create "$RESULT_DIR/$configuration-iphonesimulator/${scheme}/${scheme}.framework/${scheme}" "$RESULT_DIR/${configuration}-iphoneos/${scheme}/${scheme}.framework/${scheme}" -output "$RESULT_DIR/${scheme}_${version}.framework/${scheme}"
if ! [ $? = 0 ] ;then
    echo "lipo create framework fail"
    exit 1
fi
