//
//  ZXBMapViewController.m
//  zxb
//
//  Created by Mac mini on 2017/12/12.
//  Copyright © 2017年 kk-macbookair. All rights reserved.
//  21

#import "ZXBMapViewController.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import <AMapLocationKit/AMapLocationKit.h>



#define kRGBA(r,g,b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]
#define kLightGrayColor kRGBA(242, 242, 247, 1)
#define kGrayColor kRGBA(186, 186, 186, 1)
#define kBlackColor  kRGBA(74, 74, 74, 1)
#define kBlueColor  kRGBA(87,153,245,1)
#define kOrangeColor   kRGBA(255,152,0,1)
#define kScreenHeight self.view.frame.size.height
#define kScreenWidth  self.view.frame.size.width
@interface ZXBMapViewController ()<AMapSearchDelegate,MAMapViewDelegate>


/**
 用户选中的精确位置
 */
@property (nonatomic,strong) NSString *selectedDestinationString;
@property (nonatomic,strong) MAMapView *mapView;
@property (nonatomic,strong) AMapSearchAPI *search;

/**
 目的地poiArray
 */
@property (nonatomic,strong) NSArray<AMapPOI *> *poiArray;
@property (nonatomic,strong) AMapLocationManager *locationManager;
@property (nonatomic,assign) BOOL isZoomIn;

/**
 半透明蒙版
 */
@property (nonatomic,strong) UIView *maskView;

/**
 选择精确地址的pickerview
 */
@property (nonatomic,strong) UIPickerView *pickerView;

/**
 pickerview上面的状态栏
 */
@property (nonatomic,strong) UIView *indicatorView;

/**
 记录pickerview选择了第几行
 */
@property (nonatomic,assign) NSInteger selectedRow;

@end

@implementation ZXBMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    //设置地图
    [self setUpMap];
    //获取当前位置
    [self getCurrentLocation];
    //搜索POI
    [self searchPOIWithKeyWordString:self.destinationString];
}
#pragma mark 隐藏顶部状态栏
- (BOOL)prefersStatusBarHidden {
    if (self.showStatusBar == NO) {
        return YES;
    }
    return NO;
}

#pragma mark 设置地图
-(void)setUpMap{
    [self showHUDWithString:@"加载中" timeIntervel:NSIntegerMax];
    ///地图需要v4.5.0及以上版本才必须要打开此选项（v4.5.0以下版本，需要手动配置info.plist）
    [AMapServices sharedServices].enableHTTPS = YES;
    //下方的导航按钮
    UIButton *naviButton = [self makeButtonWithTitleString:@"更精确的路线和导航" textColor:[UIColor whiteColor] backgroundColor:kBlueColor textAlignment:UIControlContentHorizontalAlignmentCenter cornerRadius:0];
    naviButton.frame = CGRectMake(0, kScreenHeight - 50, kScreenWidth, 50);
    [naviButton addTarget:self action:@selector(gotoMapApp) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:naviButton];
    //地图mapView
    self.mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - 50)];
    [self.view addSubview:self.mapView];
    //左上角关闭按钮
    UIButton *closeButton = [[UIButton alloc]initWithFrame:CGRectMake(15, 15, 44, 44)];
    closeButton.alpha = 0.7;
    [closeButton setBackgroundImage:[UIImage imageNamed:@"关闭"] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(closeButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    [self.mapView addSubview:closeButton];
    //左下角的返回当前位置按钮
    UIButton *goBackCurrentLocationButton = [self makeButtonWithTitleString:nil textColor:nil backgroundColor:[UIColor whiteColor] textAlignment:UIControlContentHorizontalAlignmentCenter cornerRadius:8];
    goBackCurrentLocationButton.alpha = 0.7;
    goBackCurrentLocationButton.frame = CGRectMake(15, self.mapView.frame.size.height - 50 - 15, 44, 44);
    [goBackCurrentLocationButton setImage:[UIImage imageNamed:@"gpsGoToCurrentLoaction"] forState:UIControlStateNormal];
    [goBackCurrentLocationButton addTarget:self action:@selector(goBackCurrentLocationButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    [self.mapView addSubview:goBackCurrentLocationButton];
    //rightPanel右边的面板  路况 加油站  🚥
    UIView * rightPanelView = [[UIView alloc]init];
    rightPanelView.backgroundColor = [UIColor whiteColor];
    rightPanelView.layer.cornerRadius = 8;
    rightPanelView.layer.masksToBounds = YES;
    rightPanelView.alpha = 0.7;
    rightPanelView.frame = CGRectMake(self.mapView.frame.size.width - 44 - 15, 100, 44, 44*3);
    [self.mapView addSubview:rightPanelView];
    //实时路况按钮
    UIButton *signalButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 44, 44)];
    [signalButton setImage:[UIImage imageNamed:@"signalLightOff"] forState:UIControlStateNormal];
    [signalButton addTarget:self action:@selector(signalButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [rightPanelView addSubview:signalButton];
    //地图图层按钮
    UIButton *mapLayerButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 44, 44, 44)];
    [mapLayerButton setImage:[UIImage imageNamed:@"mapLayer"] forState:UIControlStateNormal];
    [rightPanelView addSubview:mapLayerButton];
    [mapLayerButton addTarget:self action:@selector(mapLayerButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    //放大button
    UIButton *zoomButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 88, 44, 44)];
    [zoomButton setImage:[UIImage imageNamed:@"zoomin"] forState:UIControlStateNormal];
    [zoomButton addTarget:self action:@selector(zoomButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [rightPanelView addSubview:zoomButton];
    //如果您需要进入地图就显示定位小蓝点，则需要下面两行代码
    self.mapView.showsUserLocation = YES;
    self.mapView.userTrackingMode = MAUserTrackingModeFollowWithHeading;
    self.mapView.delegate = self;
    self.mapView.rotateCameraEnabled = NO;
    self.mapView.rotateEnabled = NO;
  
}
#pragma mark 持续获取当前用户的位置
-(void)getCurrentLocation{
    self.locationManager = [[AMapLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
}
#pragma mark 调用外部地图导航
/**
 打开次序为 高德地图、苹果地图，如果没有则提示下载高德地图！
 需要在plist中增加如下字段：
 <key>LSApplicationQueriesSchemes</key>
 <array>
 <string>iosamap</string>
 </array>
 */
- (void)gotoMapApp{
    NSString *fullAddress = [self.destinationString stringByAppendingString:self.selectedDestinationString];
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"iosamap://"]]) {
        // 高德地图
        // 起点为“我的位置”，终点为后台返回的address
        NSString *urlString = [[NSString stringWithFormat:@"iosamap://path?sourceApplication=applicationName&sid=BGVIS1&sname=%@&did=BGVIS2&dname=%@&dev=0&t=0",@"我的位置",fullAddress] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
    }else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"http://maps.apple.com"]]){
        // 苹果地图
        // 起点为“我的位置”，终点为后台返回的address
        NSString *urlString = [[NSString stringWithFormat:@"http://maps.apple.com/?daddr=%@",fullAddress] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
    }else{
        // 快递员没有安装上面三种地图APP，弹窗提示安装地图APP
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"请下载" message:@"请下载Apple地图或者高德地图" preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *confirmAlertAction = [UIAlertAction actionWithTitle:@"去AppStore下载地图" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSString *urlString = [@"https://itunes.apple.com/cn/app/%E9%AB%98%E5%BE%B7%E5%9C%B0%E5%9B%BE-%E7%B2%BE%E5%87%86%E5%9C%B0%E5%9B%BE-%E5%AF%BC%E8%88%AA%E5%BF%85%E5%A4%87-%E6%99%BA%E8%83%BD%E4%BA%A4%E9%80%9A%E5%AF%BC%E8%88%AA%E5%9C%B0%E5%9B%BE/id461703208?mt=8" stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
        }];
        UIAlertAction *cancelAlertAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alertController addAction:confirmAlertAction];
        [alertController addAction:cancelAlertAction];
        [self presentViewController:alertController animated:YES completion:^{
            
        }];
    }
}
#pragma mark 根据模糊地址信息，搜索精确的地址。并且返回POI（通过AMapSearchDelegate代理返回）
-(void)searchPOIWithKeyWordString:(NSString *)keyWordString{
    AMapPOIKeywordsSearchRequest *request = [[AMapPOIKeywordsSearchRequest alloc] init];
#warning 一个项目的BundleID对应一个高德地图apiKey，请在高德开放平台获取 http://lbs.amap.com/dev/key/app
    [AMapServices sharedServices].apiKey = @"d0ee27ed683777fc6c34e9fad36bca5c";
    self.search = [[AMapSearchAPI alloc] init];
    self.search.delegate = self;
    request.keywords    = keyWordString;
    [self.search AMapPOIKeywordsSearch:request];
}

#pragma mark 显示选择目的地的PickerView
-(void)showDestinationPickerViewWithDataArray:(NSArray *)dataArray{
    [self showPickerViewWithArray:dataArray];
}
#pragma mark 添加目的地的大头针
- (void)setUpDestinationPointAnnotationWithAMapPOI:(AMapPOI *)poi{
    MAPointAnnotation *pointAnnotation = [[MAPointAnnotation alloc] init];
    pointAnnotation.coordinate = CLLocationCoordinate2DMake(poi.location.latitude, poi.location.longitude);
    pointAnnotation.title = poi.name;
    pointAnnotation.subtitle = [NSString stringWithFormat:@"%@%@",poi.address,poi.tel];
    [_mapView addAnnotation:pointAnnotation];
    [self searchDrivingRoute];
}
#pragma mark 搜索驾车路线
-(void)searchDrivingRoute{
    AMapPOI *poi = self.poiArray[self.selectedRow];
    MAPointAnnotation *destinationAnnotation = [[MAPointAnnotation alloc] init];
    destinationAnnotation.coordinate = CLLocationCoordinate2DMake(poi.location.latitude, poi.location.longitude);

    AMapDrivingRouteSearchRequest *navi = [[AMapDrivingRouteSearchRequest alloc] init];

    navi.requireExtension = YES;
    navi.strategy = 5;
    /* 出发点. */
    navi.origin = [AMapGeoPoint locationWithLatitude:self.mapView.userLocation.coordinate.latitude
                                           longitude:self.mapView.userLocation.coordinate.longitude];
    /* 目的地. */
    navi.destination = [AMapGeoPoint locationWithLatitude:destinationAnnotation.coordinate.latitude
                                                longitude:destinationAnnotation.coordinate.longitude];
    [self.search AMapDrivingRouteSearch:navi];
}

-(void)addPolylineInMapViewWithCoordinatesArray:(NSArray *)coordinatesArray{
    NSInteger coordinatesArrayCount = coordinatesArray.count;
        //构造折线数据对象
        CLLocationCoordinate2D commonPolylineCoords[coordinatesArrayCount/2];


    for (int i = 0; i < coordinatesArrayCount-1; i++) {
        commonPolylineCoords[i/2].latitude = [coordinatesArray[i] floatValue];
        commonPolylineCoords[i/2].longitude = [coordinatesArray[i+1] floatValue];
    }
//    AMapPOI *poi = self.poiArray[0];
//    commonPolylineCoords[coordinatesArrayCount/2].latitude = poi.location.latitude;
//    commonPolylineCoords[coordinatesArrayCount/2].longitude = poi.location.longitude;
//        //构造折线对象
        MAPolyline *commonPolyline = [MAPolyline polylineWithCoordinates:commonPolylineCoords count:(coordinatesArrayCount/2)-1];
//
//        //在地图上添加折线对象
        [self.mapView addOverlay: commonPolyline];
    
    
    
}
#pragma mark - AMapSearchDelegate
/* 路径规划搜索回调. */
- (void)onRouteSearchDone:(AMapRouteSearchBaseRequest *)request response:(AMapRouteSearchResponse *)response
{
    
    if(response.route == nil)
    {
        return;
    }
    AMapPath *path =  response.route.paths[0];
    NSMutableArray *pathStepStringArrayM = [NSMutableArray array];
    for (AMapStep *step in path.steps) {
        NSArray *fenhaoArray = [step.polyline componentsSeparatedByString:@";"];
        for (NSString *fenhaoString in fenhaoArray) {
            NSArray *daohaoArray = [fenhaoString componentsSeparatedByString:@","];
            for (NSString *string in daohaoArray) {
                [pathStepStringArrayM addObject:string];
            }
        }
    }
    [self addPolylineInMapViewWithCoordinatesArray:pathStepStringArrayM];

}
#pragma mark - 高德地图相关的代理（都在这里了）
#pragma mark AMapSearchDelegate
/* POI 搜索回调. */
- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response
{
    [self.maskView removeFromSuperview];
    //如果poi个数为0，就显示无法找到目的地
    if (response.pois.count == 0)
    {
        [self showHUDWithString:@"无法找到目的地" timeIntervel:2.0];
        return;
    }
    NSMutableArray *destinationArrayM = [NSMutableArray array];
    self.poiArray = response.pois;
    for (AMapPOI *poi in response.pois) {
        [destinationArrayM addObject:poi.name];
    }
    [self showDestinationPickerViewWithDataArray:destinationArrayM];
    //解析response获取POI信息，具体解析见 Demo
}

#pragma mark AMapAnnotationDelegate
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation
{
    
//    注意：5.1.0后由于定位蓝点增加了平滑移动功能，如果在开启定位的情况先添加annotation，需要在此回调方法中判断annotation是否为MAUserLocation，从而返回正确的View。
    if ([annotation isKindOfClass:[MAUserLocation class]]) {
        return nil;
    }
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *pointReuseIndentifier = @"pointReuseIndentifier";
        MAPinAnnotationView*annotationView = (MAPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndentifier];
        if (annotationView == nil)
        {
            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndentifier];
        }
        annotationView.canShowCallout= YES;       //设置气泡可以弹出，默认为NO
        annotationView.animatesDrop = YES;        //设置标注动画显示，默认为NO
        annotationView.selected = YES;
        annotationView.image = [UIImage imageNamed:@"牛旺-1"];
        annotationView.pinColor = MAPinAnnotationColorRed;
        return annotationView;
    }
    return nil;
}
#pragma mark MAMapViewDelegate
- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id <MAOverlay>)overlay
{
    if ([overlay isKindOfClass:[MAPolyline class]])
    {
        MAPolylineRenderer *polylineRenderer = [[MAPolylineRenderer alloc] initWithPolyline:overlay];
        polylineRenderer.lineWidth    = 8.f;
        polylineRenderer.strokeColor  = [UIColor colorWithRed:0 green:1 blue:0 alpha:0.6];
        polylineRenderer.lineJoinType = kMALineJoinRound;
        polylineRenderer.lineCapType  = kMALineCapRound;
        return polylineRenderer;
    }
    return nil;
}
//#pragma mark - 基于SVProgressHUD的二次封装
//-(void)showWithStatus:(NSString *)string withMask:(BOOL)withMask{
//    if (withMask == true) {
//        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
//    }else{
//        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeNone];
//    }
//    [SVProgressHUD showWithStatus:string];
//    [SVProgressHUD dismissWithDelay:2.5];
//}
//-(void)showWithStatusNotAutoDismiss:(NSString *)string withMask:(BOOL)withMask{
//    if (withMask == true) {
//        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
//    }else{
//        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeNone];
//    }
//    [SVProgressHUD showWithStatus:string];
//}
//-(void)showInfoWithStatus:(NSString *)string withMask:(BOOL)withMask{
//    if (withMask == true) {
//        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
//    }else{
//        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeNone];
//    }
//    [SVProgressHUD showInfoWithStatus:string];
//}
//-(void)showSuccessWithStatus:(NSString *)string withMask:(BOOL)withMask{
//    if (withMask == true) {
//        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
//    }else{
//        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeNone];
//    }
//    [SVProgressHUD showSuccessWithStatus:string];
//
//}
//-(void)showErrorWithStatus:(NSString *)string withMask:(BOOL)withMask{
//    if (withMask == true) {
//        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
//    }else{
//        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeNone];
//    }
//    [SVProgressHUD showErrorWithStatus:string];
//}
//-(void)showProgress:(float)progressfloat withStatus:(NSString *)statusString withMask:(BOOL)withMask{
//    if (withMask == true) {
//        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
//    }else{
//        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeNone];
//    }
//    [SVProgressHUD showProgress:progressfloat status:statusString];
//}
//-(void)hideAllHUD{
//    [SVProgressHUD dismiss];
//}
#pragma mark - 快速生成带有标准样式的UI
#pragma mark 快速生成button
-(UIButton *)makeButtonWithTitleString:(NSString *)titleString textColor:(UIColor *)textColor backgroundColor:(UIColor *)backgroundColor textAlignment:(UIControlContentHorizontalAlignment *)textAlignment cornerRadius:(CGFloat)cornerRadius{
    UIButton *button = [UIButton new];
    [button setTitle:titleString forState:UIControlStateNormal];
    [button setTitleColor:textColor forState:UIControlStateNormal];
    [button setBackgroundColor:backgroundColor];
    button.layer.cornerRadius = cornerRadius;
    button.layer.masksToBounds = YES;
    button.titleLabel.adjustsFontSizeToFitWidth = YES;
    button.contentHorizontalAlignment = textAlignment;
    return button;
}
#pragma mark 快速生成label
-(UILabel *)makeLabelWithString:(NSString *)string textColor:(UIColor *)textColor textAlignment:(NSTextAlignment *)textAlignment{
    UILabel *label = [UILabel new];
    label.textColor = textColor;
    label.text = string;
    label.adjustsFontSizeToFitWidth = YES;
    label.textAlignment = textAlignment;
    return label;
}
#pragma mark 快速给UI控件设置圆角&边框等属性
- (void)makeUIWithCornerRadiusAndBorder:(UIView *)object CornerRadius:(NSInteger)cornerRadius borderColor:(UIColor *)borderColor borderWidth:(NSInteger)borderWidth{
    object.layer.masksToBounds = YES;
    object.layer.cornerRadius = cornerRadius;
    object.layer.borderColor = borderColor.CGColor;
    object.layer.borderWidth = borderWidth;
}
-(void)closeButtonTouched{
    [self.navigationController popViewControllerAnimated:YES];
    [[UIApplication sharedApplication]setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
#pragma mark - 地图UI控件的点击事件
-(void)goBackCurrentLocationButtonTouched{
    [self.mapView setCenterCoordinate:self.mapView.userLocation.location.coordinate animated:YES];
    [self.mapView reloadMap];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.mapView.userTrackingMode = MAUserTrackingModeFollowWithHeading;
    });
}
-(void)signalButtonTouched:(UIButton *)signalButton{
    if (self.mapView.showTraffic == NO) {
        self.mapView.showTraffic = YES;
        [signalButton setImage:[UIImage imageNamed:@"signalLightOn"] forState:UIControlStateNormal];
        [self showHUDWithString:@"🚥实时路况已开启" timeIntervel:1.2];
    }else{
        self.mapView.showTraffic = NO;
        [signalButton setImage:[UIImage imageNamed:@"signalLightOff"] forState:UIControlStateNormal];
        [self showHUDWithString:@"🚥实时路况已关闭" timeIntervel:1.2];
    }
}
#pragma mark - 一些自定义的HUD和PickerView
#pragma mark 显示一个半透明的蒙版
-(void)showMaskView{
    //创建一个蒙版
    self.maskView = [[UIView alloc]initWithFrame:[UIApplication sharedApplication].keyWindow.bounds];
    //指定特定component的alpha，添加到父View上并不会影响子View
    self.maskView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    //获取当前的keyWindow添加模板
    [[UIApplication sharedApplication].keyWindow addSubview:self.maskView];
    //添加点击手势
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(maskViewTouched)];
    [self.maskView addGestureRecognizer:tapGesture];
}
#pragma mark 移除半透明蒙版
-(void)maskViewTouched{
    [self.maskView removeFromSuperview];
}
#pragma mark 自定义HUD
-(void)showHUDWithString:(NSString *)string timeIntervel:(NSInteger)timeIntervel{
    [self showMaskView];
    UILabel *textLabel = [self makeLabelWithString:string textColor:[UIColor whiteColor] textAlignment:NSTextAlignmentCenter];
    textLabel.adjustsFontSizeToFitWidth = YES;
    textLabel.alpha = 0.7;
    [self makeUIWithCornerRadiusAndBorder:textLabel CornerRadius:8 borderColor:nil borderWidth:0];
    textLabel.backgroundColor = [UIColor blackColor];
    textLabel.frame = CGRectMake(kScreenWidth/2 - 100, kScreenHeight/2 - 25, 200, 50);
    [self.maskView addSubview:textLabel];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeIntervel * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.maskView removeFromSuperview];
    });
}
#pragma mark 自定义的PickerView
-(void)showPickerViewWithArray:(NSArray *)array{
    [self showMaskView];
    //先移除
    [self.pickerView removeFromSuperview];
    self.pickerView = nil;
    self.pickerView = [[UIPickerView alloc]initWithFrame:CGRectMake(0, kScreenHeight / 2, kScreenWidth, kScreenHeight / 2)];
    self.pickerView.delegate = self;
    self.pickerView.dataSource = self;
    self.pickerView.backgroundColor = [UIColor whiteColor];
    [self.maskView addSubview:self.pickerView];
    //pickview上面的状态栏
    self.indicatorView = [UIView new];
    self.indicatorView.backgroundColor = [UIColor whiteColor];
    self.indicatorView.frame = CGRectMake(0, (kScreenHeight / 2) - 44, kScreenWidth, 44);
    [self.maskView addSubview:self.indicatorView];
    UIView *seperatorView = [[UIView alloc]initWithFrame:CGRectMake(5, 42, kScreenWidth-10, 2)];
    seperatorView.backgroundColor = kLightGrayColor;
    [self.indicatorView addSubview:seperatorView];
    //左边的按钮
    UIButton *leftIndicatorButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 44, 44)];
    [leftIndicatorButton setImage:[UIImage imageNamed:@"Cancel"] forState:UIControlStateNormal];
    [leftIndicatorButton addTarget:self action:@selector(maskViewTouched) forControlEvents:UIControlEventTouchUpInside];
    [self.indicatorView addSubview:leftIndicatorButton];
    //右边的按钮
    UIButton *rightIndicatorButton = [self makeButtonWithTitleString:@"确定" textColor:kBlackColor backgroundColor:nil textAlignment:UIControlContentHorizontalAlignmentCenter cornerRadius:0];
    rightIndicatorButton.frame = CGRectMake(kScreenWidth - 60, 0, 60, 44);
    [rightIndicatorButton addTarget:self action:@selector(poiSelected) forControlEvents:UIControlEventTouchUpInside];
    [self.indicatorView addSubview:rightIndicatorButton];
}
#pragma mark - UIPickerViewDelegate&Datasource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return self.poiArray.count;
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    AMapPOI *poi = self.poiArray[row];
    self.selectedDestinationString = poi.name;
    self.selectedRow = row;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    AMapPOI *poi = self.poiArray[row];
    return poi.name;
}
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel* pickerLabel = (UILabel*)view;
    if (!pickerLabel){
        pickerLabel = [[UILabel alloc] init];
        pickerLabel.adjustsFontSizeToFitWidth = YES;
        [pickerLabel setTextAlignment:NSTextAlignmentCenter];
        [pickerLabel setBackgroundColor:[UIColor clearColor]];
        [pickerLabel setFont:[UIFont systemFontOfSize:25 weight:UIFontWeightLight]];
    }
    pickerLabel.text=[self pickerView:pickerView titleForRow:row forComponent:component];
    return pickerLabel;
}
#pragma mark - UI上的点击事件
-(void)zoomButtonTouched:(UIButton *)zoomButton{
    if (self.isZoomIn == NO) {
        self.isZoomIn = YES;
        [self.mapView setZoomLevel:16 animated:YES];
        [zoomButton setImage:[UIImage imageNamed:@"zoomout"] forState:UIControlStateNormal];
    }else{
        self.isZoomIn = NO;
        [self.mapView setZoomLevel:10 animated:YES];
        [zoomButton setImage:[UIImage imageNamed:@"zoomin"] forState:UIControlStateNormal];
    }
}
-(void)poiSelected{
    //隐藏
    [self maskViewTouched];
    AMapPOI *poi = self.poiArray[self.selectedRow];
    [self setUpDestinationPointAnnotationWithAMapPOI:poi];
}
-(void)mapLayerButtonTouched{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"地图图层类型" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *alertAction1 = [UIAlertAction actionWithTitle:@"普通模式（系统默认)" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.mapView.mapType = MAMapTypeStandard;
    }];
    UIAlertAction *alertAction2 = [UIAlertAction actionWithTitle:@"卫星地图" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.mapView.mapType = MAMapTypeSatellite;
    }];
    UIAlertAction *alertAction3 = [UIAlertAction actionWithTitle:@"夜间视图" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.mapView.mapType = MAMapTypeStandardNight;
    }];
    UIAlertAction *alertAction4 = [UIAlertAction actionWithTitle:@"导航视图(较少标记物，更好体验）" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.mapView.mapType = MAMapTypeNavi;
    }];
    UIAlertAction *alertAction5 = [UIAlertAction actionWithTitle:@"公交视图" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.mapView.mapType = MAMapTypeBus;
    }];
    UIAlertAction *alertAction6 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertController addAction:alertAction1];
    [alertController addAction:alertAction2];
    [alertController addAction:alertAction3];
    [alertController addAction:alertAction4];
    [alertController addAction:alertAction5];
    [alertController addAction:alertAction6];
    [self presentViewController:alertController animated:YES completion:^{
        
    }];
}
@end
