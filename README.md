# EasyAmap
## 超好集成的高德地图（界面优美，功能强大）
## 视频演示demo（如果下载，复制到浏览器播放）
http://ac-rxWgcQwd.clouddn.com/fbacc4da398ec86dbbd0.mp4
### 使用方式：将ZXBMapViewController.h和ZXBMapViewController.m文件加入到项目中即可
A.注意Podfile的依赖pod 'AMap3DMap'
pod 'AMapSearch'
pod 'AMapLocation'
pod 'AMapNavi'
pod 'SVProgressHUD'
B.由于定位和导航涉及到用户隐私，需要在plist中增加如下字段
<key>LSApplicationQueriesSchemes</key>
<array>
<string>iosamap</string>
</array>
<key>LSRequiresIPhoneOS</key>
<true/>
<key>NSLocationAlwaysUsageDescription</key>
<string>App需要您的同意,才能始终访问位置</string>
<key>NSLocationUsageDescription</key>
<string>App需要您的同意,才能访问位置</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>App需要您的同意,才能在使用期间访问位置</string>
C.一个项目的BundleID对应一个高德地图apiKey，请在高德开放平台获取 http://lbs.amap.com/dev/key/app
[AMapServices sharedServices].apiKey = @"你的key";
