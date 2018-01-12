# 超好集成的EasyiOSMap-基于高德地图（界面优美，功能强大）
- 视频演示demo（如果不能下载，复制到浏览器地址栏播放）</br>
http://www.ac-rxWgcQwd.clouddn.com/fbacc4da398ec86dbbd0.mp4
- 使用方式：将ZXBMapViewController.h和ZXBMapViewController.m文件加入到项目中即可
- 注意Podfile的依赖</br>
pod 'AMap3DMap'</br>
pod 'AMapSearch'</br>
pod 'AMapLocation'</br>
pod 'AMapNavi'</br>
pod 'SVProgressHUD'</br>
- 由于定位和导航涉及到用户隐私，需要在plist中增加如下字段</br>
\<key\>LSApplicationQueriesSchemes\</key\></br>
\<array\></br>
\<string\>iosamap\</string\></br>
\</array\></br>
\<key\>LSRequiresIPhoneOS\</key\></br>
\<true/\></br>
\<key\>NSLocationAlwaysUsageDescription\</key\></br>
\<string\>App需要您的同意,才能始终访问位置\</string\></br>
\<key\>NSLocationUsageDescription\</key\></br>
\<string\>App需要您的同意,才能访问位置\</string\></br>
\<key\>NSLocationWhenInUseUsageDescription\</key\></br>
\<string\>App需要您的同意,才能在使用期间访问位置\</string\></br>

- 一个项目的BundleID对应一个高德地图apiKey！</br>
请在高德开放平台获取 http://www.lbs.amap.com/dev/key/app</br>
[AMapServices sharedServices].apiKey = @"你的key";
