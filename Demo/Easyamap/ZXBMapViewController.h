//
//  ZXBMapViewController.h
//  zxb
//
//  Created by Mac mini on 2017/12/12.
//  Copyright © 2017年 kk-macbookair. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZXBMapViewController :UIViewController

/**
 传入你要去的目的地字符串，模糊的地址也可以！
 如深圳医院，然后他会进一步提示用户选择是深圳哪个医院。
 */
@property (nonatomic,strong) NSString *destinationString;


@end
