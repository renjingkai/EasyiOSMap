//
//  ViewController.m
//  Easyamap
//
//  Created by GTX1060 on 2018/1/10.
//  Copyright © 2018年 GTX1060. All rights reserved.
//

#import "ViewController.h"
#import "ZXBMapViewController.h"
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *destinationTextfield;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    
    
}
- (IBAction)goToMapButtonTouch:(UIButton *)sender {
    ZXBMapViewController *mapVC = [ZXBMapViewController new];
    mapVC.showStatusBar = YES;
    mapVC.destinationString = self.destinationTextfield.text;
    [self showViewController:mapVC sender:nil];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
