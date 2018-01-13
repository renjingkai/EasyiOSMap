# 超好集成的EasyiOSMap-基于高德地图（界面优美，功能强大）
![Alt text](https://github.com/renjingkai/EasyiOSMap/blob/master/screenshot.jpg)
- 视频演示（复制到浏览器地址栏播放，清晰流畅）</br>
http://www.ac-rxWgcQwd.clouddn.com/fbacc4da398ec86dbbd0.mp4
- GIF演示（第一次播放有卡顿，需要缓冲）</br>
![Alt text](https://github.com/renjingkai/EasyiOSMap/blob/master/GifDemo.gif)
## 使用方式：
- 将ZXBMapViewController.h，ZXBMapViewController.m文件还有切图文件夹中的图标加入到项目,并且复制以下代码
```
ZXBMapViewController *mapVC = [ZXBMapViewController new];
/**
传入你要去的目的地字符串，模糊的地址也可以！
如深圳医院，然后他会进一步提示用户选择是深圳哪个医院。
*/
mapVC.destinationString = @“深圳医院”;
[self showViewController:mapVC sender:nil];
```
## 编译前请确保以下操作已完成：
- 一个项目的BundleID对应一个高德地图apiKey,apiKey在不同的项目中没有通用性！</br>
请在高德开放平台获取 http://www.lbs.amap.com/dev/key/app</br>
```
[AMapServices sharedServices].apiKey = @"你的key";
```
- 注意Podfile的依赖</br>
```
pod 'AMap3DMap'</br>
pod 'AMapSearch'</br>
pod 'AMapLocation'</br>
pod 'AMapNavi'</br>
pod 'SVProgressHUD'</br>
```
- 由于定位涉及到用户隐私，需要在plist中增加如下字段</br>
```
<key>NSLocationAlwaysUsageDescription</key>
<string>App需要您的同意,才能始终访问位置</string>
<key>NSLocationUsageDescription</key>
<string>App需要您的同意,才能访问位置</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>App需要您的同意,才能在使用期间访问位置</string>
```
- 导航需要跳转并打开第三方地图，需要在plist中增加如下字段</br>
打开次序为 高德地图、苹果地图，如果没有则提示下载高德地图
```
<key>LSApplicationQueriesSchemes</key>
<array>
<string>iosamap</string>
</array>
```
- 别忘了把切图文件夹中的图标放到Assets.xcassets中

